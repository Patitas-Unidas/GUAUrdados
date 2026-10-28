const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const TOKENS_INVALIDOS = [
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
];

exports.notificarEmergencia = onDocumentCreated("emergencias/{emergenciaId}", async (event) => {
  const snap = event.data;
  if (!snap) return;
  const e = snap.data();
  const db = getFirestore();
  const messaging = getMessaging();

  const titulo = e.nombrePerro
    ? `🚨 Emergencia: ${e.nombrePerro}`
    : "🚨 Emergencia en la comunidad";
  const body = [e.tipo, e.ubicacion].filter(Boolean).join(" · ") || "Se necesita ayuda";
  const data = {
    emergenciaId: event.params.emergenciaId,
    idPerro: e.idPerro || "",
    tipo: e.tipo || "",
  };
  const android = { priority: "high" };

  // Perro desconocido: se avisa a quienes están suscritos al tema "emergencias".
  if (!e.idPerro) {
    await messaging.send({ topic: "emergencias", notification: { title: titulo, body }, data, android });
    await snap.ref.update({ notificados: "topic", notificadoEn: FieldValue.serverTimestamp() });
    return;
  }

  // Seguidores del perro, sin contar a quien emitió la alerta.
  const perro = await db.doc(`perros/${e.idPerro}`).get();
  const seguidores = (perro.get("seguidores") || []).filter((uid) => uid !== e.creadoPor);
  if (seguidores.length === 0) {
    await snap.ref.update({ notificados: 0, notificadoEn: FieldValue.serverTimestamp() });
    return;
  }

  const usuarios = await db.getAll(...seguidores.map((uid) => db.doc(`usuarios/${uid}`)));
  const tokens = [...new Set(usuarios.flatMap((u) => u.get("tokens") || []))];

  let enviados = 0;
  for (let i = 0; i < tokens.length; i += 500) {
    const lote = tokens.slice(i, i + 500);
    const res = await messaging.sendEachForMulticast({
      tokens: lote,
      notification: { title: titulo, body },
      data,
      android,
    });
    enviados += res.successCount;

    // Limpia tokens que ya no sirven.
    const invalidos = lote.filter((_, idx) => {
      const r = res.responses[idx];
      return !r.success && TOKENS_INVALIDOS.includes(r.error?.code);
    });
    for (const token of invalidos) {
      const q = await db.collection("usuarios").where("tokens", "array-contains", token).get();
      await Promise.all(q.docs.map((d) => d.ref.update({ tokens: FieldValue.arrayRemove(token) })));
    }
  }

  await snap.ref.update({ notificados: enviados, notificadoEn: FieldValue.serverTimestamp() });
});
