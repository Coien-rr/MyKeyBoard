//
//  AppDelegate.swift
//  myKeyBoard
//
//  Created by Coien on 2024/3/4.
//

import Cocoa
import Foundation
import IOKit
import IOKit.usb

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var Menu: NSMenu!
    var statusItem: NSStatusItem?
    @IBOutlet weak var ICON: NSMenu!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        
        let itemImage = NSImage(named: "Angle")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        statusItem?.menu = Menu
        // 使用这个函数来获取USB设备列表
        let usbDeviceNames = getConnectedUSBDevices()
        statusItem?.button?.title =  " " + usbDeviceNames[0]
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func Update(_ sender: Any) {
        print("Todo Update")
    }
    
    @IBAction func Quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func getConnectedUSBDevices() -> [String] {
        var productNames: [String] = []
        let masterPort = UnsafeMutablePointer<mach_port_t>.allocate(capacity: 1)
        guard IOMasterPort(mach_port_t(MACH_PORT_NULL), masterPort) == KERN_SUCCESS else {
            print("Failed to create a master I/O Kit port")
            return productNames
        }

        let matchingDict = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
        let iterator = UnsafeMutablePointer<io_iterator_t>.allocate(capacity: 1)
        guard IOServiceGetMatchingServices(masterPort.pointee, matchingDict, iterator) == KERN_SUCCESS else {
            print("Failed to get matching services")
            return productNames
        }

        var service: io_object_t
        repeat {
            service = IOIteratorNext(iterator.pointee)
            if service != 0 {
                let serviceDict = UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
                if IORegistryEntryCreateCFProperties(service, serviceDict, kCFAllocatorDefault, 0) == KERN_SUCCESS {
                    if let dict = serviceDict.pointee?.takeRetainedValue() as? [String: Any],
                                       let productName = dict["USB Product Name"] as? String,
                                       !productName.contains("Hub") {
                                        productNames.append(productName)
                                    }
                                }
                IOObjectRelease(service)
            }
        } while service != 0

        IOObjectRelease(iterator.pointee)
        return productNames
    }
}

