//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import package_info_plus_macos
import path_provider_macos
import shared_preferences_macos
import soundpool_macos
import wakelock_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FLTPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FLTPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SwiftSoundpoolPlugin.register(with: registry.registrar(forPlugin: "SwiftSoundpoolPlugin"))
  WakelockMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockMacosPlugin"))
}
