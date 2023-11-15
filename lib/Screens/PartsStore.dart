import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class PartsStore extends StatefulWidget {
  const PartsStore({super.key, required this.brand});
  final String brand;
  @override
  State<PartsStore> createState() => _PartsStoreState();
}

class _PartsStoreState extends State<PartsStore> {
  final search = FloatingSearchBarController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black,
        title: Text(widget.brand.toUpperCase()),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // body: Stack(
      //   children: [
      //     // Your list of parts
      //     _buildHorizontalSlide(),
      //     // The floating search bar
      //     Positioned(
      //       top: 0,
      //       left: 0,
      //       right: 0,
      //       child: buildFloatingSearchBar(),
      //     ),
      //   ],
      // ),
      body: const Center(
        child: Text("No parts availble yet"),
      ),
    ));
  }

  _buildHorizontalSlide() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Parts List",
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(
            height: 500,
            child: ListView.builder(
                itemBuilder: (context, index) => _tile(index), itemCount: 5),
          ),
        ],
      ),
    );
  }

  _tile(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), border: Border.all()),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                  "https://contentinfo.autozone.com/znetcs/product-info/en/US/epa/DG905/image/10/"),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 200,
                height: 100,
                child: Text(
                  "Some item name that's very long and detailed that it needs all the space it can take",
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 200,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 100,
                    color: Colors.yellow,
                    child: const Center(
                      child: Text(
                        "500 Da",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ]),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      controller: search,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),

      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((color) {
                return GestureDetector(
                    onTap: () {
                      print(color);
                    },
                    child: Container(height: 50, color: color));
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
