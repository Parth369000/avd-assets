import 'dart:ui';
import 'package:avd_assets/Screens/AddProductPage.dart' show ProductInputScreen;
import 'package:avd_assets/controller/common_controller.dart';
import 'package:avd_assets/controller/product_controller.dart';
import 'package:avd_assets/model/category_model.dart';
import 'package:avd_assets/model/colors.dart';
import 'package:avd_assets/model/department_model.dart';
import 'package:avd_assets/model/location_model.dart';
import 'package:avd_assets/model/product_model.dart';
import 'package:avd_assets/Screens/filter_page.dart';
import 'package:avd_assets/Screens/ProductDetailPage.dart';
import 'package:avd_assets/widgets/products.dart';
import 'package:avd_assets/widgets/shimmer_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Data lists
  List<productModel> productList = [];
  List<getDept> departmentList = [];
  List<Category> categoryList = [];
  List<GetLocation> locationList = [];
  List<productModel>? filterProduct = [];

  // Controllers
  late productController controller;
  final CommonController commonController = CommonController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables
  bool isLoading = true;
  bool filterApplied = false;
  List<String> filterCategories = [];
  List<String> filterDepartment = [];
  List<String> filterLocations = [];
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Initialize product controller
    controller = Get.put<productController>(productController());
    getProducts();

    // Listen for search focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    // Load initial data
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        getInitializeData();
        isLoading = false;
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void getInitializeData() async {
    await getDepartmentsData();
    await getLocationsData();
    await getCategories();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("categories", []);
    await prefs.setStringList("locations", []);
    await prefs.setStringList("department", []);
    controller.searchController.clear();
  }

  Future<void> getLocationsData() async {
    try {
      List<dynamic> locations = await commonController.fetchData('location');
      setState(() {
        locationList = locations
            .map((location) => GetLocation.fromJson(location))
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }
  }

  Future<void> getCategories() async {
    try {
      List<dynamic> categories = await commonController.fetchData('category');
      setState(() {
        categoryList =
            categories.map((category) => Category.fromJson(category)).toList();
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> getDepartmentsData() async {
    String userRole = "";
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role") ?? "";
    });
    try {
      List<dynamic> departments = await commonController.fetchData('dept');
      setState(() {
        departmentList = departments
            .map((department) => getDept.fromJson(department))
            .toList();

        switch(userRole){
          case "KDept":
            departmentList = departmentList.where((dept) => dept.name == 'Kitchen').toList();
            break;
          case "VDept":
            departmentList = departmentList.where((dept) => dept.name == 'Video').toList();
            break;
          case "DDept":
            departmentList = departmentList.where((dept) => dept.name == 'Decoration').toList();
            break;
          case "Admin":
            departmentList = departmentList;
            break;
        }
      });
    } catch (e) {
      debugPrint('Error loading departments: $e');
    }
  }

  Future<void> getProducts() async {
    controller.getProduct();
    setState(() {
      productList = controller.productList;
    });
  }

  Widget _buildFilterChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary1.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: primary1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: primary1.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 12,
              color: primary1,
            ),
          ),
        ],
      ),
    );
  }

  // This widget displays the applied filters if any.
  Widget buildAppliedFilters() {
    if (filterCategories.isEmpty && filterDepartment.isEmpty && filterLocations.isEmpty) {
      return const SizedBox(); // Return empty widget if no filters are applied.
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8,),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              "Active Filters",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (filterCategories.isNotEmpty)
                  ...filterCategories.map((category) => _buildFilterChip("Category: $category")),
                if (filterDepartment.isNotEmpty)
                  ...filterDepartment.map((dept) => _buildFilterChip("Department: $dept")),
                if (filterLocations.isNotEmpty)
                  ...filterLocations.map((location) => _buildFilterChip("Location: $location")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> filterData({String searchQuery = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve lists from SharedPreferences.
    List<String> categoriesFromPrefs = prefs.getStringList("categories") ?? [];
    List<String> departmentsFromPrefs = prefs.getStringList("department") ?? [];
    List<String> locationsFromPrefs = prefs.getStringList("locations") ?? [];

    final filteredProducts = productList.where((product) {
      // For multiple categories, check if any selected category matches the product's categoryName.
      final matchesCategory = categoriesFromPrefs.isEmpty ||
          categoriesFromPrefs.any((cat) =>
          cat.toLowerCase() == (product.categoryName ?? '').toLowerCase());

      // For department, allow any matching storage entry.
      final matchesDepartment = departmentsFromPrefs.isEmpty ||
          (product.storage?.any((storage) =>
              departmentsFromPrefs.contains(storage.department)) ??
              false);

      // For location, if a department filter is applied, make sure that the storage's department is among them.
      final matchesLocation = locationsFromPrefs.isEmpty ||
          (product.storage?.any((storage) {
            bool deptOk = departmentsFromPrefs.isEmpty ||
                departmentsFromPrefs.contains(storage.department);
            return locationsFromPrefs.contains(storage.location) && deptOk;
          }) ??
              false);

      return matchesCategory && matchesDepartment && matchesLocation;
    }).toList();

    setState(() {
      // Update state variables so that buildAppliedFilters() shows the applied filters.
      filterCategories = categoriesFromPrefs;
      filterDepartment = departmentsFromPrefs;
      filterLocations = locationsFromPrefs;
      filterProduct = filteredProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: const ShimmerLoading(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primary1,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate the opacity for smooth fade-out
                double opacity = (constraints.maxHeight - kToolbarHeight) /
                    (160 - kToolbarHeight);
                opacity = opacity.clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // Background with gradient and pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary1,
                              Color.lerp(primary1, secondary2, 0.7)!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative circles
                            Positioned(
                              top: -50,
                              right: -20,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -60,
                              left: -30,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // App title and logo
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: opacity,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.asset(
                                      'assets/avd.jpg',
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'AVD Assets',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search bar and filter button
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          // Search bar
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(_isSearchFocused ? 12 : 28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                focusNode: _searchFocusNode,
                                cursorColor: primary1,
                                controller: controller.searchController,
                                onChanged: (value) => setState(() {
                                  filterProduct = controller.filterProductList;
                                  filterApplied = true;
                                }),
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  color: primary1,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Search products...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(_isSearchFocused ? 12 : 28),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 20,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: _isSearchFocused ? primary1 : Colors.grey[600],
                                    size: 24,
                                  ),
                                  suffixIcon: controller.searchController.text.isNotEmpty
                                      ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      controller.searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                      : null,
                                ),
                              ),
                            ),
                          ),

                          // Filter button
                          Container(
                            margin: const EdgeInsets.only(left: 12),
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await Get.to(
                                        () => FilterPage(
                                      categoryList: categoryList,
                                      departmentList: departmentList,
                                      locationList: locationList,
                                    ),
                                    transition: Transition.rightToLeft,
                                  )?.whenComplete(() async => await filterData());
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.tune,
                                      size: 24,
                                      color: primary1,
                                    ),
                                    if (filterCategories.isNotEmpty || filterDepartment.isNotEmpty || filterLocations.isNotEmpty)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: secondary2,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        body: Obx(() {
          if (controller.isLoading.value) {
            return const ShimmerLoading();
          }

          // Determine if any filter has been applied
          bool isFilterApplied = (filterCategories.isNotEmpty) ||
              (filterDepartment.isNotEmpty) ||
              filterLocations.isNotEmpty;

          // If a filter is applied but there are no matching products, show a message
          if (isFilterApplied && filterProduct!.isEmpty) {
            return _buildEmptyState(
              icon: Icons.filter_list,
              title: 'No matching products',
              message: 'Try adjusting your filters to see more products',
            );
          }

          // If user has entered a search query and no matching products are found
          if (controller.searchController.text.isNotEmpty && filterProduct!.isEmpty) {
            return _buildEmptyState(
              icon: Icons.search_off,
              title: 'No results found',
              message: 'Try a different search term',
            );
          }

          // If there are no products at all
          if (controller.productList.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products available',
              message: 'Add some products to get started',
            );
          }

          return LiquidPullToRefresh(
            springAnimationDurationInMilliseconds: 300,
            height: 80,
            color: primary1,
            backgroundColor: Colors.white,
            showChildOpacityTransition: false,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              controller.getProduct();
              setState(() {
                filterProduct!.clear();
                productList = controller.productList;
                filterDepartment = [];
                filterCategories = [];
                filterLocations = [];
                controller.searchController.clear();
              });
            },
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Applied filters section
                  SliverToBoxAdapter(
                    child: buildAppliedFilters(),
                  ),

                  // Products header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filterProduct!.isNotEmpty ? filterProduct!.length : productList.length} items',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Products grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final productModel product = (filterProduct!.isNotEmpty ? filterProduct! : productList)[index];
                          return _buildAnimatedProductCard(
                            product: product,
                            index: index,
                          );
                        },
                        childCount: filterProduct!.isNotEmpty ? filterProduct!.length : productList.length,
                      ),
                    ),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildAnimatedProductCard({
    required productModel product,
    required int index,
  }) {
    // Calculate a staggered delay based on index
    final delay = Duration(milliseconds: 50 * (index % 10));

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      // delay: delay,
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Get.to(
              () => ProductDetailPage(nproduct: product),
          transition: Transition.fadeIn,
        ),
        child: Hero(
          tag: 'product_${product.productId}',
          child: Material(
            type: MaterialType.transparency,
            child: ProductCard(nproduct: product),
          ),
        ),
      ),
    );
  }
}

