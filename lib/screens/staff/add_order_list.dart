import 'package:cheez_bro/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../components/drop_down_button.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/password_strong.dart';
import 'staff_order_list.dart';

class AddOrderList extends StatefulWidget {
  const AddOrderList({super.key});

  @override
  AddOrderListState createState() => AddOrderListState();
}

class AddOrderListState extends State<AddOrderList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController quantityCtrl = TextEditingController();
  TextEditingController pricePerItemCtrl = TextEditingController();
  TextEditingController itemPriceCtrl = TextEditingController();
  TextEditingController totalPriceCtrl = TextEditingController();
  int totalPrice = 0;

  String? selectedOrderType;
  String? selectedCategory;
  String? selectedItem;
  String? selectedSize;
  String? selectedDeliveryType;
  String? selectedPayment;
  int pricePerItem = 0;
  int quantity = 1;
  int itemPrice = 0;

  String? status = 'Pending';

  bool isLoading = false;

  List<Map<String, dynamic>> items = [];
  List<String> categories = [];
  List<String> itemNames = [];
  List<String> sizes = [];
  Map<String, Set<String>> itemSet = {};
  Map<String, Set<String>> sizeSet = {};
  Map<String, int> priceMap = {};

  @override
  void initState() {
    super.initState();
    fetchMenuData();
  }

  Future<void> fetchMenuData() async {
    QuerySnapshot categorysnapshot =
        await firestore.collection('category').get();
    QuerySnapshot menusnapshot = await firestore.collection('menu').get();
    Set<String> categorySet = {};
    Map<String, Set<String>> tempItemSet = {};
    Map<String, Set<String>> tempSizeSet = {};
    Map<String, int> priceMapping = {};

    for (var doc in categorysnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      categorySet.add(data['categoryName']);
    }

    for (var doc in menusnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      String category = data['categoryName'];
      String itemName = data['itemName'];
      String size = data['size'];

      tempItemSet.putIfAbsent(category, () => {}).add(itemName);
      tempSizeSet.putIfAbsent(itemName, () => {}).add(size);

      priceMapping['${itemName}_$size'] =
          int.tryParse(data['price'].toString()) ?? 0;
    }

    List<String> itemNames = [];
    if (selectedCategory != null && tempItemSet.containsKey(selectedCategory)) {
      itemNames = tempItemSet[selectedCategory]?.toList() ?? [];
    }

    setState(() {
      categories = categorySet.toList();
      itemSet = tempItemSet;
      sizeSet = tempSizeSet;
      priceMap = priceMapping;
      this.itemNames = itemNames;
    });
  }

  void updatePrice() {
    if (selectedItem != null && selectedSize != null) {
      pricePerItem = priceMap['${selectedItem}_$selectedSize'] ?? 0;
      if (selectedOrderType == "Pathao") {
        pricePerItem = (pricePerItem * 0.735).round();
      }
    }

    itemPrice = quantity * pricePerItem;

    pricePerItemCtrl.text = pricePerItem.toString();
    itemPriceCtrl.text = itemPrice.toString();
    setState(() {});
  }

  void updateItemNames() {
    if (selectedCategory != null && itemSet.containsKey(selectedCategory)) {
      setState(() {
        itemNames = itemSet[selectedCategory]?.toList() ?? [];
      });
    }
  }

  void updateSizes() {
    if (selectedItem != null && sizeSet.containsKey(selectedItem)) {
      setState(() {
        sizes = sizeSet[selectedItem]?.toList() ?? [];
      });
    }
  }

  void addItemToList() {
    if (selectedOrderType != null &&
        selectedCategory != null &&
        selectedItem != null &&
        selectedSize != null &&
        quantity > 0) {
      setState(() {
        // Calculate item price
        int itemPrice = quantity * pricePerItem;

        // Add item to the list
        items.add({
          'orderType': selectedOrderType,
          'category': selectedCategory,
          'itemName': selectedItem,
          'size': selectedSize,
          'pricePerItem': pricePerItem,
          'quantity': quantity,
          'itemPrice': itemPrice,
        });

        totalPrice += itemPrice;
        totalPriceCtrl.text = totalPrice.toString();

        selectedOrderType = null;
        selectedCategory = null;
        selectedItem = null;
        selectedSize = null;
        quantityCtrl.clear();
        pricePerItem = 0;
        itemPrice = 0;
        pricePerItemCtrl.clear();
        itemPriceCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AddEditTitleSection(title: 'Add New Order Details'),
                      const SizedBox(height: 30),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              DropDownButton(
                                label: 'Select Order Type',
                                items: const ['Regular', 'Pathao'],
                                selectedItem: selectedOrderType,
                                onChanged: (value) {
                                  setState(() {
                                    selectedOrderType = value;
                                    selectedCategory = null;
                                    selectedItem = null;
                                    selectedSize = null;
                                    pricePerItem = 0;
                                    quantity = 1;
                                  });
                                },
                                icon: Icons.shopping_cart,
                              ),
                              if (selectedOrderType != null) ...[
                                DropDownButton(
                                  label: 'Select Category',
                                  items: categories,
                                  selectedItem: selectedCategory,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value;
                                      selectedItem = null;
                                      selectedSize = null;
                                      pricePerItem = 0;
                                      quantity = 1;
                                    });
                                    updateItemNames();
                                  },
                                  icon: Icons.category,
                                ),
                                if (selectedCategory != null) ...[
                                  DropDownButton(
                                    label: 'Select Item Name',
                                    items: itemNames,
                                    selectedItem: selectedItem,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedItem = value;
                                        selectedSize = null;
                                        pricePerItem = 0;
                                        quantity = 1;
                                      });
                                      updateSizes();
                                    },
                                    icon: Icons.label,
                                  ),
                                  if (selectedItem != null) ...[
                                    DropDownButton(
                                      label: 'Select Size',
                                      items: sizes,
                                      selectedItem: selectedSize,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSize = value;
                                          updatePrice();
                                        });
                                      },
                                      icon: Icons.straighten,
                                    ),
                                  ]
                                ],
                              ],
                              InputField(
                                controller: quantityCtrl,
                                label: "Quantity",
                                icon: Icons.archive,
                                onChanged: (value) {
                                  setState(() {
                                    quantity = int.tryParse(value) ?? 1;
                                    updatePrice();
                                  });
                                },
                              ),
                              InputField(
                                controller: pricePerItemCtrl,
                                label: "Price Per Product",
                                icon: Icons.attach_money,
                                readOnly: true,
                              ),
                              InputField(
                                controller: itemPriceCtrl,
                                label: "Item Price",
                                icon: Icons.monetization_on,
                                readOnly: true,
                                onChanged: (value) {
                                  setState(() {
                                    quantity = int.tryParse(value) ?? 1;
                                    updatePrice();
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              CustomButton(
                                onPressed: () {
                                  addItemToList();
                                },
                                isLoading: isLoading,
                                text: 'Add Item',
                              ),
                              const SizedBox(height: 20),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return ListTile(
                                    title: Text(
                                      "Item Name: ${item['itemName']} \nSize:${item['size']} \nQuantity: ${item['quantity']}",
                                      style: style2(
                                        16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Order Type: ${item['orderType']}\nCategory: ${item['category']}\nPrice: ${item['itemPrice'].toStringAsFixed(0)}",
                                      style: style2(
                                        16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          totalPrice -=
                                              item['itemPrice'] as int;
                                          items.removeAt(index);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              DropDownButton(
                                label: 'Select Delivery Type',
                                items: const ['Dine-in', 'Parcel'],
                                selectedItem: selectedDeliveryType,
                                onChanged: (value) => setState(
                                    () => selectedDeliveryType = value),
                                icon: Icons.delivery_dining,
                              ),
                              DropDownButton(
                                label: 'Select Payment',
                                items: const ['Paid', 'Unpaid'],
                                selectedItem: selectedPayment,
                                onChanged: (value) =>
                                    setState(() => selectedPayment = value),
                                icon: Icons.payment,
                              ),
                              InputField(
                                controller: totalPriceCtrl,
                                label: 'Total Price',
                                icon: Icons.attach_money,
                                readOnly: true,
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                      CustomButton(
                        onPressed: () async {
                          await addInformation(
                            context: context,
                            targetWidget: const StaffOrderList(),
                            controllers: {
                              'items': items,
                              'sale': totalPrice,
                              'deliveryType': selectedDeliveryType,
                              'Payment': selectedPayment,
                              'status': status,
                            },
                            name: '',
                            option: '',
                            name1: '',
                            option1: '',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: PasswordStrengthChecker(),
                            collectionName: 'orders',
                            fieldsToSubmit: [
                              'items',
                              'sale',
                              'deliveryType',
                              'Payment',
                              'status',
                            ],
                            addTimestamp: true,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Submit Order',
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
