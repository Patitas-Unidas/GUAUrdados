import 'package:flutter/material.dart';

const _coral = Color.fromRGBO(222, 79, 65, 1);
const _gris = Color.fromRGBO(56, 54, 53, .5);
const _fondoContador = Color.fromRGBO(247, 229, 220, 1);

class RegistrarAlimentacion extends StatefulWidget {
  const RegistrarAlimentacion({
    super.key,
    required this.perro,
  });
  final String perro;

  @override
  State<RegistrarAlimentacion> createState() => _RegistrarAlimentacionState();
}

class _RegistrarAlimentacionState extends State<RegistrarAlimentacion> {
  int _currentSelectionAlimento = 0;
  int _currentSelectionTipoCantidad = 0;
  int punados = 1;
  int gramos = 50;

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.sizeOf(context).height;
    final teclado = MediaQuery.viewInsetsOf(context).bottom;

    // El teclado empuja la hoja hacia arriba y el contenido se desplaza,
    // en lugar de desbordarse.
    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: Container(
        constraints: BoxConstraints(maxHeight: alto * 0.85),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(249, 240, 235, 1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título (fijo)
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.flatware, size: 40, color: _coral),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registrar Alimentación',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.perro,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, color: _gris),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 30,
              thickness: 1,
              color: Color.fromRGBO(56, 54, 53, .3),
            ),

            // Contenido desplazable
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Etiqueta('TIPO DE ALIMENTO'),
                    NavigationBar(
                      onDestinationSelected: (index) =>
                          setState(() => _currentSelectionAlimento = index),
                      selectedIndex: _currentSelectionAlimento,
                      indicatorColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      destinations: const <Widget>[
                        NavigationDestination(
                          icon: Icon(Icons.food_bank, size: 28),
                          label: 'Croquetas',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.restaurant, size: 28),
                          label: 'Comida húmeda',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.fastfood, size: 28),
                          label: 'Otro',
                        ),
                      ],
                    ),
                    if (_currentSelectionAlimento == 2)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.white,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            hintText: 'Escribe el tipo de alimento aquí.',
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    const _Etiqueta('CANTIDAD APROXIMADA'),
                    NavigationBar(
                      onDestinationSelected: (index) =>
                          setState(() => _currentSelectionTipoCantidad = index),
                      selectedIndex: _currentSelectionTipoCantidad,
                      indicatorColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      destinations: const <Widget>[
                        NavigationDestination(
                          icon: Icon(Icons.handshake_outlined, size: 28),
                          label: 'Puñados',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.scale, size: 28),
                          label: 'Gramos',
                        ),
                      ],
                    ),
                    if (_currentSelectionTipoCantidad == 0)
                      _Contador(
                        valor: punados,
                        unidad: 'puñados',
                        onMenos: () => setState(() {
                          if (punados != 1) punados--;
                        }),
                        onMas: () => setState(() {
                          if (punados <= 9) punados++;
                        }),
                      )
                    else
                      _Contador(
                        valor: gramos,
                        unidad: 'gramos',
                        onMenos: () => setState(() {
                          if (gramos > 25) gramos -= 25;
                        }),
                        onMas: () => setState(() {
                          if (gramos < 500) gramos += 25;
                        }),
                      ),
                  ],
                ),
              ),
            ),

            // Botón Guardar Registro (fijo abajo)
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _coral,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.flatware, color: Colors.white, size: 28),
                label: const Text(
                  'Guardar Registro',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _gris),
      );
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.valor,
    required this.unidad,
    required this.onMenos,
    required this.onMas,
  });
  final int valor;
  final String unidad;
  final VoidCallback onMenos;
  final VoidCallback onMas;

  @override
  Widget build(BuildContext context) => Card(
        color: _fondoContador,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BotonRedondo(icono: Icons.remove, onPressed: onMenos),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$valor',
                    style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w600, color: _coral),
                  ),
                  Text(unidad, style: const TextStyle(fontSize: 18)),
                ],
              ),
              _BotonRedondo(icono: Icons.add, onPressed: onMas),
            ],
          ),
        ),
      );
}

class _BotonRedondo extends StatelessWidget {
  const _BotonRedondo({required this.icono, required this.onPressed});
  final IconData icono;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icono),
          iconSize: 25,
          color: _coral,
          onPressed: onPressed,
        ),
      );
}
