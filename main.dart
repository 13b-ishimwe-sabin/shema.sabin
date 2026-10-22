import 'package:flutter/material.dart';

void main() {
  runApp(const StockManagerApp());
}

class StockManagerApp extends StatelessWidget {
  const StockManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ibarura ry\'Ibicuruzwa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const StockDashboard(),
    );
  }
}

class StockItem {
  String id;
  String name;
  int quantity;
  double price;

  StockItem({required this.id, required this.name, required this.quantity, required this.price});
}

class StockDashboard extends StatefulWidget {
  const StockDashboard({super.key});

  @override
  State<StockDashboard> createState() => _StockDashboardState();
}

class _StockDashboardState extends State<StockDashboard> {
  // Urutonde rw'ibicuruzwa by'icyitegererezo
  final List<StockItem> _stockItems = [
    StockItem(id: '1', name: 'Umuceri (Amashashi)', quantity: 15, price: 1500.0),
    StockItem(id: '2', name: 'Amavuta yo guteka', quantity: 3, price: 3500.0),
    StockItem(id: '3', name: 'Isabune z\'imiti', quantity: 20, price: 800.0),
  ];

  // Utwuma tuyobora inyandiko zinjizwa (Controllers)
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  // Kubara amafaranga yose hamwe y'ibicuruzwa bihari
  double get _totalValue => _stockItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  // Uburyo bwo gufungura agafomu ko kwinjiza/guhindura igicuruzwa (CRUD)
  void _showForm({StockItem? item}) {
    if (item != null) {
      _nameController.text = item.name;
      _quantityController.text = item.quantity.toString();
      _priceController.text = item.price.toString();
    } else {
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: SingleChildScrollView(
          // Twakoresheje ikoranabuhanga rya nested ListTile aho gukoresha multi-child Column
          child: ListTile(
            title: Text(
              item == null ? 'Injiza Igicuruzwa Gishya' : 'Hindura Amakuru',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: ListTile(
              contentPadding: EdgeInsets.zero,
              title: TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Izina ry\'Igicuruzwa', border: OutlineInputBorder()),
              ),
              subtitle: ListTile(
                contentPadding: const EdgeInsets.only(top: 10),
                title: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Ingano (Quantity)', border: OutlineInputBorder()),
                ),
                subtitle: ListTile(
                  contentPadding: const EdgeInsets.only(top: 10),
                  title: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Igiciro kuri kimwe (Frw)', border: OutlineInputBorder()),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        if (_nameController.text.isEmpty ||
                            _quantityController.text.isEmpty ||
                            _priceController.text.isEmpty) return;

                        setState(() {
                          if (item == null) {
                            // Kwinjiza gishya
                            _stockItems.add(StockItem(
                              id: DateTime.now().toString(),
                              name: _nameController.text,
                              quantity: int.tryParse(_quantityController.text) ?? 0,
                              price: double.tryParse(_priceController.text) ?? 0.0,
                            ));
                          } else {
                            // Guhindura ibyahindutse
                            item.name = _nameController.text;
                            item.quantity = int.tryParse(_quantityController.text) ?? 0;
                            item.price = double.tryParse(_priceController.text) ?? 0.0;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Text(item == null ? 'Bika Igicuruzwa' : 'Emeza Impinduka'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Urugero rw\'Isitoki (${_totalValue.toStringAsFixed(0)} Frw)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      // CustomScrollView ikoresha slivers aho gukoresha children widgets
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _stockItems[index];
                final isLow = item.quantity <= 5; // Iburira niba ibisigaye ari bike
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLow ? Colors.amber.shade200 : Colors.teal.shade100,
                      child: Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Igiteranyo: ${(item.price * item.quantity).toStringAsFixed(0)} Frw (${item.price.toStringAsFixed(0)} Frw/kipande)'),
                    trailing: SizedBox(
                      width: 100,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(item: item),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _stockItems.removeWhere((element) => element.id == item.id);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _stockItems.length,
            ),
          ),
        ],
      ),
      // Akabuto ko kwinjiza ibicuruzwa bishya
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
