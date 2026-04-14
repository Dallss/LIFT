//
//  Settings.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/15/26.
//

import SwiftUI
import Observation

@Observable
class Settings {
    @AppStorage("isDarkMode") var isDarkMode = false
}
