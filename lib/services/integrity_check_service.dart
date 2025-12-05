import 'package:flutter/material.dart';
import 'package:safe_device/safe_device.dart';

class IntegrityCheckService {
  Future<bool> checkDeviceSecurity(BuildContext context) async {
    bool isRooted = false;
    bool isEmulator = false;

    try {
      // Check for root (Android) or jailbreak (iOS)
      isRooted = await SafeDevice.isJailBroken;

      // Check if running on an emulator/simulator
      isEmulator = await SafeDevice.isRealDevice == false;
      if (isRooted) {
        return true;
      } else if (isEmulator) {
        return true;
        // ACTION: Emulator detected. Might also indicate an unsafe environment.
      } else {
        return false;
        // ACTION: Device is deemed safe. Proceed normally.
      }
    } catch (e) {
      // Handle potential exceptions during the check
      print('Security check failed: $e');
      return false;
    }
  }
}
