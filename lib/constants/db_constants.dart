import 'package:cloud_firestore/cloud_firestore.dart';

final adRef = FirebaseFirestore.instance.collection("advertisement");
final youtubeRef = FirebaseFirestore.instance.collection("youtube");
final productsRef = FirebaseFirestore.instance.collection("products");
final filtersRef = FirebaseFirestore.instance.collection("filters");
final customerRef = FirebaseFirestore.instance.collection("customer");
final questionRef = FirebaseFirestore.instance.collection("question");
