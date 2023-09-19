import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController=TextEditingController();
  final TextEditingController _quantityController=TextEditingController();
  List<Map<String,dynamic>>  _items=[];
  final _shoppingBox=Hive.box('my_box');
  @override

  void initState() {

    super.initState();
    _refreshItems(); //load data when app starts
  }

  void _refreshItems(){
    final data=_shoppingBox.keys.map((key){
      final item=_shoppingBox.get(key);
      return{ "key":key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();

    setState(() {
      _items=data.reversed.toList();
      //log(_items.length);
      // we use reversed to sort items in order from the latest to the oldest
    });
  }

  //create new item
  Future<void> _createItem(Map<String,dynamic> newItem) async {
    await _shoppingBox.add(newItem); //0,1,2
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey,Map<String,dynamic> item) async {
    await _shoppingBox.put(itemKey,item);
    _refreshItems();  //update the UI
  }
  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems(); //update the UI

    //Dispaly a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An item hasn been deleted')));
  }
  // print('amount data is ${_shoppingBox.length}');

  void _showForm (BuildContext ctx,int? itemKey) async{

    if(itemKey!=null){
      final existingItem=
      _items.firstWhere((element) =>element['key']== itemKey);
      _nameController.text=existingItem['name'];
      _quantityController.text=existingItem['quantity'];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 3,

        builder: (_)=>Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
          ),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'name'),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(hintText: 'quantity'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: ()async {
                  if(itemKey==null) {
                    _createItem({
                      "name": _nameController.text,
                      "quantity": _quantityController.text
                    });
                  }
                  if(itemKey!=null) {
                    _updateItem(itemKey,{
                      "name": _nameController.text.trim(),
                      "quantity": _quantityController.text.trim()
                    });
                  }
                  // clear the text fields
                  _nameController.text='';
                  _quantityController.text='';
                  Navigator.of(context).pop();  //close the botton sheet
                },
                child: Text(itemKey==null ? 'Create New':'update'),
              ),
            ],
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive'),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index){
            final currentItem=_items[index];
            return Card(
              color: Colors.grey.shade400,
              margin: const EdgeInsets.all(18),
              elevation: 3,
              child: ListTile(
                title: Text(currentItem['name']),
                subtitle: Text(currentItem['quantity'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //edit button
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: ()=>
                          _showForm(context, currentItem['key']),

                    ),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: ()=>_deleteItem(currentItem['key'])),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>_showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

