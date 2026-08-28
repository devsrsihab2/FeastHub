import 'package:first_project/data/dummy_data.dart';
import 'package:first_project/screens/categories.dart';
import 'package:first_project/screens/favorite_meal.dart';
import 'package:first_project/screens/filters.dart';
import 'package:first_project/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

const kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegan: false,
  Filter.vegetarian: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  Map<Filter, bool> _selectedFilters = kInitialFilters;
  // slect page
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => FiltersScreen(currentFilter: _selectedFilters),
        ),
      );

      setState(() {
        _selectedFilters = result ?? kInitialFilters;
      });

      print('the filter ${result}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final availabeMeal = dummyMeals.where((meal) {
      if (_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (_selectedFilters[Filter.vegan]! && !meal.isVegan) {
        return false;
      }

      return true;
    }).toList();

    Widget activePage = CategoriesScreen(availableMeals: availabeMeal);
    var activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      activePage = const FavoriteScreen();
      activePageTitle = 'Your Favorites';
    }

    return Scaffold(
      appBar: AppBar(title: Text(activePageTitle)),
      body: activePage,
      drawer: MainDrawer(onSelectedScreen: _setScreen),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: "Categories",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
        ],
      ),
    );
  }
}
