import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBfOuB1PG8N8zagvMh00zcb--UGPDAx1mY",
  authDomain: "autoparts-libya.firebaseapp.com",
  projectId: "autoparts-libya",
  storageBucket: "autoparts-libya.firebasestorage.app",
  messagingSenderId: "280826904350",
  appId: "1:280826904350:web:bb8a4b1759628042b7530f",
);

List<Map<String, dynamic>> vendorsDB = [
  {
    'id': 'ahmed',
    'username': 'ahmed',
    'password': '123',
    'shopName': 'مؤسسة أحمد للقطع',
    'phone': '218910808100',
    'address': 'طرابلس - شارع الجمهورية',
    'latitude': 32.8872,
    'longitude': 13.1913,
  },
  {
    'id': 'mohamed',
    'username': 'mohamed',
    'password': '123',
    'shopName': 'محل محمد السريع',
    'phone': '218910808100',
    'address': 'بنغازي - شارع جمال عبدالناصر',
    'latitude': 32.1194,
    'longitude': 20.0872,
  },
];

List<Map<String, dynamic>> shoppingCart = [];

String generateProductCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random();
  String code = 'PRD-';
  for (int i = 0; i < 6; i++) {
    code += chars[random.nextInt(chars.length)];
  }
  return code;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const AutoPartsApp());
}

class AutoPartsApp extends StatelessWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قطع غيار السيارات - ليبيا',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD32F2F)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// ==================== 1. شاشة تسجيل الدخول ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userType = 'buyer';
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    if (userType == 'vendor') {
      final vendor = vendorsDB.firstWhere(
            (v) => v['username'] == usernameController.text && v['password'] == passwordController.text,
        orElse: () => {},
      );
      if (vendor.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بيانات غير صحيحة'), backgroundColor: Colors.red),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VendorSetupScreen(vendor: vendor)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BuyerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.directions_car, size: 70, color: Color(0xFFD32F2F)),
                  ),
                  const SizedBox(height: 20),
                  const Text('قطع غيار السيارات', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('ليبيا', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              userType = 'buyer';
                              usernameController.clear();
                              passwordController.clear();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: userType == 'buyer' ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Text('زبون', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => userType = 'vendor'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: userType == 'vendor' ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Text('بائع', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (userType == 'vendor') ...[
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'اسم المستخدم',
                        prefixIcon: const Icon(Icons.person, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text('جرب: ahmed / 123', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFD32F2F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(userType == 'buyer' ? 'دخول كزبون' : 'دخول كبائع', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 2. شاشة إعداد البائع (مع GPS آمن 100%) ====================
class VendorSetupScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;
  const VendorSetupScreen({super.key, required this.vendor});

  @override
  State<VendorSetupScreen> createState() => _VendorSetupScreenState();
}

class _VendorSetupScreenState extends State<VendorSetupScreen> {
  final shopNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool isGettingLocation = false;
  String? locationStatus;

  @override
  void initState() {
    super.initState();
    shopNameController.text = widget.vendor['shopName'] ?? '';
    phoneController.text = widget.vendor['phone'] ?? '';
    addressController.text = widget.vendor['address'] ?? '';
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
      locationStatus = 'جاري تحديد الموقع...';
    });

    try {
      final location = await _getBrowserLocation();
      if (location != null) {
        setState(() {
          widget.vendor['latitude'] = location['lat'];
          widget.vendor['longitude'] = location['lng'];
          isGettingLocation = false;
          locationStatus = '✓ تم تحديد الموقع: ${location['lat']!.toStringAsFixed(4)}, ${location['lng']!.toStringAsFixed(4)}';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديد موقعك بنجاح'), backgroundColor: Colors.green),
          );
        }
      } else {
        setState(() {
          isGettingLocation = false;
          locationStatus = '⚠️ لم نتمكن من تحديد الموقع. يرجى السماح للمتصفح باستخدام الموقع أو استخدام الإدخال اليدوي.';
        });
      }
    } catch (e) {
      setState(() {
        isGettingLocation = false;
        locationStatus = '⚠️ حدث خطأ أثناء تحديد الموقع.';
      });
    }
  }

  // دالة تحديد الموقع الآمنة تماماً من أخطاء Null Safety
  Future<Map<String, double>?> _getBrowserLocation() async {
    if (!kIsWeb) return null;
    try {
      final geolocation = html.window.navigator.geolocation;
      if (geolocation == null) return null;

      final position = await geolocation.getCurrentPosition();

      // استخراج القيم بأمان تام وتحويلها إلى double
      final double? lat = position.coords?.latitude?.toDouble();
      final double? lng = position.coords?.longitude?.toDouble();

      if (lat != null && lng != null) {
        return {'lat': lat, 'lng': lng};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void saveAndContinue() {
    if (shopNameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول'), backgroundColor: Colors.red),
      );
      return;
    }

    widget.vendor['shopName'] = shopNameController.text;
    widget.vendor['phone'] = phoneController.text;
    widget.vendor['address'] = addressController.text;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VendorDashboard(vendor: widget.vendor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد حساب البائع'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('مرحباً بك!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('أهلاً ${widget.vendor['username']}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 24),

              const Text('اسم المؤسسة / المحل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: shopNameController, decoration: const InputDecoration(hintText: 'مثال: مؤسسة الأمل', prefixIcon: Icon(Icons.store), border: OutlineInputBorder())),
              const SizedBox(height: 16),

              const Text('رقم هاتف واتساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '218910808100', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder())),
              const SizedBox(height: 16),

              const Text('عنوان المحل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: addressController, maxLines: 2, decoration: const InputDecoration(hintText: 'أدخل العنوان بالتفصيل', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('تحديد موقع المحل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isGettingLocation ? null : getCurrentLocation,
                        icon: isGettingLocation
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.my_location),
                        label: Text(isGettingLocation ? 'جاري التحديد...' : 'استخدم موقعي الحالي (GPS)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Center(child: Text('— أو —', style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => _LocationInputDialog(vendor: widget.vendor),
                          ).then((location) {
                            if (location != null) {
                              setState(() {
                                widget.vendor['latitude'] = location['lat'];
                                widget.vendor['longitude'] = location['lng'];
                                locationStatus = '✓ تم تحديد الموقع يدوياً: ${location['lat'].toStringAsFixed(4)}, ${location['lng'].toStringAsFixed(4)}';
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.edit_location, color: Colors.blue),
                        label: const Text('إدخال الإحداثيات يدوياً', style: TextStyle(color: Colors.blue)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    if (locationStatus != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: locationStatus!.contains('✓') ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          locationStatus!,
                          style: TextStyle(
                            color: locationStatus!.contains('✓') ? Colors.green[700] : Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    const Text(
                      '💡 للحصول على الإحداثيات يدوياً:\n1. افتح Google Maps\n2. اضغط مطولاً على موقعك\n3. انسخ الأرقام',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: saveAndContinue,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('حفظ والانتقال', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationInputDialog extends StatefulWidget {
  final Map<String, dynamic> vendor;
  const _LocationInputDialog({required this.vendor});

  @override
  State<_LocationInputDialog> createState() => _LocationInputDialogState();
}

class _LocationInputDialogState extends State<_LocationInputDialog> {
  final latController = TextEditingController();
  final lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vendor['latitude'] != null) {
      latController.text = widget.vendor['latitude'].toString();
      lngController.text = widget.vendor['longitude'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إدخال إحداثيات الموقع'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('خط العرض (Latitude):'),
          TextField(
            controller: latController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(hintText: 'مثال: 32.8872'),
          ),
          const SizedBox(height: 12),
          const Text('خط الطول (Longitude):'),
          TextField(
            controller: lngController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(hintText: 'مثال: 13.1913'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            final lat = double.tryParse(latController.text);
            final lng = double.tryParse(lngController.text);
            if (lat != null && lng != null) {
              Navigator.pop(context, {'lat': lat, 'lng': lng});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أرقام غير صحيحة'), backgroundColor: Colors.red));
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

// ==================== 3. صفحة إضافة منتج ====================
class AddProductPage extends StatefulWidget {
  final Map<String, dynamic> vendor;
  const AddProductPage({super.key, required this.vendor});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  String generatedCode = '';
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    generatedCode = generateProductCode();
  }

  Future<void> addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('املأ الاسم والسعر'), backgroundColor: Colors.red));
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'productCode': generatedCode,
        'vendorId': widget.vendor['id'],
        'name': nameController.text,
        'price': priceController.text,
        'description': descriptionController.text,
        'image': imageController.text.isNotEmpty ? imageController.text : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الحفظ ✓\nالكود: $generatedCode'), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD32F2F), width: 2)),
                child: Column(
                  children: [
                    const Text('كود المنتج', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(generatedCode, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F), fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم القطعة *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category, color: Color(0xFFD32F2F)))),
              const SizedBox(height: 16),
              TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (د.ل) *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money, color: Color(0xFFD32F2F)))),
              const SizedBox(height: 16),
              TextField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description, color: Color(0xFFD32F2F)))),
              const SizedBox(height: 16),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'رابط الصورة', hintText: 'https://...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.link, color: Colors.grey))),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : addProduct,
                  icon: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save, size: 24),
                  label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ المنتج', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 4. لوحة تحكم البائع ====================
class VendorDashboard extends StatefulWidget {
  final Map<String, dynamic> vendor;
  const VendorDashboard({super.key, required this.vendor});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  String vendorSearchQuery = '';

  Stream<QuerySnapshot> getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('vendorId', isEqualTo: widget.vendor['id'])
        .snapshots();
  }

  Future<void> deleteProduct(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('products').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف'), backgroundColor: Colors.orange));
    }
  }

  void logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الخروج'),
        content: const Text('هل تريد الخروج من التطبيق؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لا')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logout();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.vendor['shopName']),
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'خروج',
              onPressed: logout,
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (v) => setState(() => vendorSearchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو الكود...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: vendorSearchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      setState(() => vendorSearchQuery = '');
                    })
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getProductsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (vendorSearchQuery.isEmpty) return true;
                      return data['name'].toString().contains(vendorSearchQuery) || data['productCode'].toString().contains(vendorSearchQuery);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('لا توجد منتجات', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final product = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: product['image'] != null
                                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(product['image'], width: 60, height: 60, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 60)))
                                : Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                            title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${product['price']} د.ل', style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                                Text('كود: ${product['productCode']}', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.blue[900])),
                              ],
                            ),
                            trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteProduct(docId)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductPage(vendor: widget.vendor))),
          icon: const Icon(Icons.add),
          label: const Text('إضافة منتج'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      ),
    );
  }
}

// ==================== 5. واجهة الزبون ====================
class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  State<BuyerScreen> createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  String searchQuery = '';
  final Map<String, double> mockDistances = {'ahmed': 6.5, 'mohamed': 90.2};
  final TextEditingController searchController = TextEditingController();

  Stream<QuerySnapshot> getAllProductsStream() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  void openGoogleMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() => shoppingCart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت إضافة "${product['name']}" للسلة'), backgroundColor: Colors.green));
  }

  void _openWhatsApp(Map<String, dynamic> product) {
    final vendor = vendorsDB.firstWhere((v) => v['id'] == product['vendorId'], orElse: () => {});
    if (vendor.isEmpty) return;
    final phone = vendor['phone'].toString().replaceAll(RegExp(r'\D'), '');
    final message = 'السلام عليكم، أريد الاستفسار عن:\n📦 ${product['name']}\n🔢 الكود: ${product['productCode']}\n💰 السعر: ${product['price']} د.ل';
    launchUrl(Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}'), mode: LaunchMode.externalApplication);
  }

  void logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الخروج'),
        content: const Text('هل تريد الخروج من التطبيق؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لا')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              shoppingCart.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logout();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قطع غيار السيارات'),
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'خروج',
              onPressed: logout,
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم، الكود، أو المحل...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() => searchQuery = '');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getAllProductsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                    final docs = snapshot.data!.docs;
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final vendor = vendorsDB.firstWhere((v) => v['id'] == data['vendorId'], orElse: () => {});
                      final shopName = vendor['shopName']?.toString() ?? '';
                      if (searchQuery.isEmpty) return true;
                      return data['name'].toString().contains(searchQuery) || shopName.contains(searchQuery) || data['productCode'].toString().contains(searchQuery);
                    }).toList();

                    filteredDocs.sort((a, b) {
                      final distA = mockDistances[(a.data() as Map<String, dynamic>)['vendorId']] ?? 999;
                      final distB = mockDistances[(b.data() as Map<String, dynamic>)['vendorId']] ?? 999;
                      return distA.compareTo(distB);
                    });

                    if (filteredDocs.isEmpty) return const Center(child: Text('لا توجد نتائج', style: TextStyle(color: Colors.grey)));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final product = filteredDocs[index].data() as Map<String, dynamic>;
                        final vendor = vendorsDB.firstWhere((v) => v['id'] == product['vendorId'], orElse: () => {});
                        final distance = mockDistances[product['vendorId']];
                        final hasLocation = vendor['latitude'] != null && vendor['longitude'] != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product['image'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product['image'],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c,e,s) => const SizedBox(height: 200, child: Icon(Icons.image, size: 60)),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                if (distance != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: distance < 10 ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: distance < 10 ? Colors.green[200]! : Colors.orange[200]!)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.near_me, size: 14, color: distance < 10 ? Colors.green[700] : Colors.orange[700]),
                                      const SizedBox(width: 4),
                                      Text('${distance.toStringAsFixed(1)} كم', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: distance < 10 ? Colors.green[700] : Colors.orange[700])),
                                    ]),
                                  ),
                                const SizedBox(height: 8),
                                Text(product['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('كود: ${product['productCode']}', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.blue[900])),
                                const SizedBox(height: 4),
                                Text('${product['price']} د.ل', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                                const SizedBox(height: 8),
                                Text('${vendor['shopName']}', style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${vendor['address']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),

                                if (hasLocation)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: InkWell(
                                      onTap: () => openGoogleMaps(vendor['latitude'], vendor['longitude']),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue[200]!),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.map, size: 18, color: Colors.blue[700]),
                                            const SizedBox(width: 8),
                                            Text('عرض على الخريطة', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 13)),
                                            const SizedBox(width: 4),
                                            Icon(Icons.open_in_new, size: 14, color: Colors.blue[700]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: OutlinedButton.icon(onPressed: () => _openWhatsApp(product), icon: const Icon(Icons.chat, color: Colors.green), label: const Text('استفسار', style: TextStyle(color: Colors.green)))),
                                    const SizedBox(width: 8),
                                    Expanded(child: ElevatedButton.icon(onPressed: () => addToCart(product), icon: const Icon(Icons.shopping_cart), label: const Text('شراء'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}