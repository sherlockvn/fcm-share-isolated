import Flutter
import FirebaseCore
import FirebaseMessaging

@objc public class FcmSharedIsolatePlugin: NSObject, FlutterPlugin, MessagingDelegate {
    internal init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fcm_shared_isolate", binaryMessenger: registrar.messenger())
        let instance = FcmSharedIsolatePlugin(channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    let channel: FlutterMethodChannel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getToken":
            Messaging.messaging().delegate = self
            print("Getting a token")
            Messaging.messaging().token { token, error in
                print("Some result")
                if let error = error {
                    print("Some error")
                    result(FlutterError(code: "unknown", message: nil, details: nil))
                } else if let token = token {
                    print("Some ok")
                    result(String(token))
                }
            }
        case "requestPermission":
            let arguments = call.arguments as! NSDictionary;
            if #available(iOS 10.0, *) {
                var authOptions: UNAuthorizationOptions = []
                if arguments["sound"] as! Bool {
                    authOptions.insert(.sound)
                }
                if arguments["alert"] as! Bool {
                    authOptions.insert(.alert)
                }
                if arguments["badge"] as! Bool {
                    authOptions.insert(.badge)
                }
                if arguments["provisional"] as! Bool {
                    if #available(iOS 12.0, *) {
                        authOptions.insert(.provisional)
                    }
                }

                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: { [] granted, error in
                        if let error = error {
                            result(FlutterError(code: "perm", message: nil, details: error.localizedDescription))
                            return
                        }

                        result(granted)
                    }
                )

                UIApplication.shared.registerForRemoteNotifications()
            } else {
                var notificationTypes: UIUserNotificationType = []
                if arguments["sound"] as! Bool {
                    notificationTypes.insert(.sound)
                }
                if arguments["alert"] as! Bool {
                    notificationTypes.insert(.alert)
                }
                if arguments["badge"] as! Bool {
                    notificationTypes.insert(.badge)
                }

                let settings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)

                UIApplication.shared.registerForRemoteNotifications()

                result(true)
            }
        default:
            assertionFailure(call.method)
            result(FlutterMethodNotImplemented)
        }
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken token: String?) {
        channel.invokeMethod("token", arguments: [token])
    }

    /*public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {

    }*/
}
