import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authCtrl = Get.find();
  final _picker = ImagePicker();
  final Location _locService = Location();

  var avatarFile = Rxn<File>();
  var isLoadingLocation = false.obs;
  var currentLocation = Rxn<LocationData>();
  var locationError = ''.obs;

  /// Permite al usuario escoger una foto de la galería.
  Future<void> pickAvatar() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      avatarFile.value = File(picked.path);
      // Aquí podrías subirla a Appwrite Storage o guardarla localmente.
    }
  }

  /// Obtiene la ubicación actual del dispositivo.
  Future<void> fetchLocation() async {
    isLoadingLocation.value = true;
    locationError.value = '';
    try {
      final perm = await _locService.requestPermission();
      if (perm != PermissionStatus.granted) {
        throw 'Permiso denegado';
      }
      final data = await _locService.getLocation();
      currentLocation.value = data;
    } catch (e) {
      locationError.value = e.toString();
    } finally {
      isLoadingLocation.value = false;
    }
  }
}
