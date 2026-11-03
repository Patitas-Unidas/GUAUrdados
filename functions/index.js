const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const REGION = "southamerica-west1";
const HORAS_SIN_COMER = 24;
const HORAS_SIN_AGUA = 24;

const TOKENS_INVALIDOS = [
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
];

function perrosDe(e) {
  if (Array.isArray(e.idsPerros)) {
    return { ids: e.idsPerros, nombres: e.nombresPerros || [] };
  }
  return e.idPerro ? { ids: [e.idPerro], nombres: [e.nombrePerro || "Perrito"] } : { ids: [], nombres: [] };
}

function listar(nombres) {
  if (nombres.length <= 1) return nombres[0] || "";
  return `${nombres.slice(0, -1).join(", ")} y ${nombres[nombres.length - 1]}`;
}

async function tokensDeSeguidores(idsPerros, excluir) {
  const db = getFirestore();
  const perros = await db.getAll(...idsPerros.map((id) => db.doc(`perros/${id}`)));
  const seguidores = [...new Set(perros.flatMap((p) => p.get("seguidores") || []))].filter((uid) => uid !== excluir);
  if (seguidores.length === 0) return [];
  const usuarios = await db.getAll(...seguidores.map((uid) => db.doc(`usuarios/${uid}`)));
  return [...new Set(usuarios.flatMap((u) => u.get("tokens") || []))];
}

async function enviar(tokens, notification, data) {
  const db = getFirestore();
  const messaging = getMessaging();
  let enviados = 0;
  for (let i = 0; i < tokens.length; i += 500) {
    const lote = tokens.slice(i, i + 500);
    const res = await messaging.sendEachForMulticast({ tokens: lote, notification, data, android: { priority: "high" } });
    enviados += res.successCount;

    const invalidos = lote.filter((_, idx) => {
      const r = res.responses[idx];
      return !r.success && TOKENS_INVALIDOS.includes(r.error?.code);
    });
    for (const token of invalidos) {
      const q = await db.collection("usuarios").where("tokens", "array-contains", token).get();
      await Promise.all(q.docs.map((d) => d.ref.update({ tokens: FieldValue.arrayRemove(token) })));
    }
  }
  return enviados;
}

exports.notificarEmergencia = onDocumentCreated({ document: "emergencias/{emergenciaId}", region: REGION }, async (event) => {
  const snap = event.data;
  if (!snap) return;
  const e = snap.data();
  const { ids, nombres } = perrosDe(e);

  const titulo = ids.length ? `🚨 Emergencia: ${listar(nombres)}` : "🚨 Emergencia en la comunidad";
  const body = [e.tipo, e.ubicacion].filter(Boolean).join(" · ") || "Se necesita ayuda";
  const data = {
    emergenciaId: event.params.emergenciaId,
    idPerro: ids[0] || "",
    idsPerros: ids.join(","),
    tipo: e.tipo || "",
  };

  // Perro desconocido: se avisa a quienes están suscritos al tema "emergencias".
  if (ids.length === 0) {
    await getMessaging().send({ topic: "emergencias", notification: { title: titulo, body }, data, android: { priority: "high" } });
    await snap.ref.update({ notificados: "topic", notificadoEn: FieldValue.serverTimestamp() });
    return;
  }

  const tokens = await tokensDeSeguidores(ids, e.creadoPor);
  const enviados = await enviar(tokens, { title: titulo, body }, data);
  await snap.ref.update({ notificados: enviados, notificadoEn: FieldValue.serverTimestamp() });
});

const CIERRES = {
  resuelta: "✅ Resuelta",
  veterinario: "🩺 En atención veterinaria",
  falsa_alarma: "Falsa alarma",
};

exports.notificarCierreEmergencia = onDocumentUpdated({ document: "emergencias/{emergenciaId}", region: REGION }, async (event) => {
  const antes = event.data?.before.data();
  const despues = event.data?.after.data();
  if (!antes || !despues) return;
  if ((antes.estado || "en_curso") !== "en_curso" || !CIERRES[despues.estado]) return;

  const { ids, nombres } = perrosDe(despues);
  const titulo = ids.length ? `Terminó la emergencia de ${listar(nombres)}` : "Terminó una emergencia de la comunidad";
  const body = [CIERRES[despues.estado], despues.nota].filter(Boolean).join(" · ");
  const data = { emergenciaId: event.params.emergenciaId, idsPerros: ids.join(","), estado: despues.estado };

  if (ids.length === 0) {
    await getMessaging().send({ topic: "emergencias", notification: { title: titulo, body }, data });
    return;
  }
  const tokens = await tokensDeSeguidores(ids, despues.creadoPor);
  await enviar(tokens, { title: titulo, body }, data);
});

exports.alertarSinComerNiAgua = onSchedule({ schedule: "every 60 minutes", region: REGION, timeZone: "America/Santiago" }, async () => {
  const db = getFirestore();
  const ahora = Date.now();
  const perros = await db.collection("perros").get();

  for (const perro of perros.docs) {
    const p = perro.data();
    const avisosRef = db.doc(`avisos_cuidado/${perro.id}`);
    const avisados = (await avisosRef.get()).data() || {};
    const cambios = {};

    for (const [campo, horas, texto] of [
      ["ultimaComidaEn", HORAS_SIN_COMER, "no ha comido"],
      ["ultimaAguaEn", HORAS_SIN_AGUA, "no ha tomado agua"],
    ]) {
      const ultima = p[campo]?.toMillis?.();
      if (!ultima || ahora - ultima < horas * 3600000 || avisados[campo] === ultima) continue;

      const transcurridas = Math.floor((ahora - ultima) / 3600000);
      const tokens = await tokensDeSeguidores([perro.id]);
      await enviar(
        tokens,
        { title: `${p.nombre || "Un perrito"} ${texto} en ${transcurridas} h`, body: "¿Alguien puede revisarlo y registrarlo en la app?" },
        { idPerro: perro.id, tipo: campo === "ultimaAguaEn" ? "sin_agua" : "sin_comer" },
      );
      cambios[campo] = ultima;
    }

    if (Object.keys(cambios).length) await avisosRef.set(cambios, { merge: true });
  }
});
