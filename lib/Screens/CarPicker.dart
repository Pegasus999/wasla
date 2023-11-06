import 'package:flutter/material.dart';
import 'package:list_picker/list_picker.dart';
import 'package:wasla/Constants.dart';
import 'package:wasla/Models/Cars.dart';
import 'package:wasla/Screens/PartsStore.dart';
import 'package:wasla/Services/API.dart';

class CarPicker extends StatefulWidget {
  const CarPicker({super.key});

  @override
  State<CarPicker> createState() => _CarPickerState();
}

class _CarPickerState extends State<CarPicker> {
  final brand = TextEditingController();
  final model = TextEditingController();
  final generation = TextEditingController();
  bool loading = false;
  String? img;
  final brands = [
    "Alfa Romeo",
    "Aston Martin",
    "Audi",
    "Baic",
    "BMW",
    "Brilliance",
    "Bugatti",
    "BYD",
    "Cadillac",
    "Changan",
    "Chery",
    "Chevrolet",
    "Chrysler",
    "Citroen",
    "Dacia",
    "Daewoo",
    "Daihatsu",
    "DFSK",
    "Dodge",
    "DS",
    "Emgrand",
    "Faw",
    "Ferrari",
    "Fiat",
    "Fiat Professional",
    "Ford",
    "Geely",
    "Great Wall",
    "Haima",
    "Honda",
    "Hummer",
    "Hyundai",
    "Infiniti",
    "Iran Khodro",
    "Isuzu",
    "JAC",
    "Jaguar",
    "Jeep",
    "Kia",
    "Lada",
    "Lamborghini",
    "Lancia",
    "Land Rover",
    "Lexus",
    "Mahindra",
    "Maserati",
    "Mazda",
    "McLaren",
    "Mercedes-Benz",
    "MG",
    "Mini",
    "Mitsubishi",
    "Nissan",
    "Opel",
    "Peugeot",
    "Porsche",
    "Renault",
    "Rolls-Royce",
    "Rover",
    "Saab",
    "Seat",
    "Skoda",
    "Smart",
    "SsangYong",
    "Subaru",
    "Suzuki",
    "Tata",
    "Toyota",
    "Volkswagen",
    "Volvo",
    "Zotye",
  ];

  List<Model> models = [];
  List<String> modelsNames = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    brand.addListener(() => _onBrandSelect());
    model.addListener(() => _onModelSelect());
  }

  _onModelSelect() async {
    setState(() {
      img = null;
    });
    int index = models.indexWhere((el) => el.name == model.text);

    String? src = await API.getCarImage(models[index].url);

    if (src != null) {
      setState(() {
        img = src;
      });
    }
  }

  _onBrandSelect() async {
    setState(() {
      loading = true;
    });
    List<Model>? list = await API.getCarModels(brand.text);
    if (list != null) {
      setState(() {
        models = list;
        loading = false;
        modelsNames = list.map((model) => model.name).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pick your Car"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: img != null
                          ? Image.network(
                              img!,
                              width: 200,
                              height: 150,
                            )
                          : model.text.isNotEmpty
                              ? Constants.loading
                              : const Center(
                                  child: Text("Pick A Car"),
                                )),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 350,
                  child: ListPickerField(
                    label: "Brand",
                    items: brands,
                    controller: brand,
                  ),
                ),
                const SizedBox(height: 20),
                loading
                    ? Constants.loading
                    : modelsNames.isNotEmpty
                        ? SizedBox(
                            width: 350,
                            child: ListPickerField(
                              label: "Model",
                              items: modelsNames,
                              controller: model,
                            ),
                          )
                        : const SizedBox(),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PartsStore(brand: brand.text),
                          ));
                    },
                    style: ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)))),
                    child: const SizedBox(
                        height: 50,
                        width: 200,
                        child: Center(child: Text("Confirm"))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
