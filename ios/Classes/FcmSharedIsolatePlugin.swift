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
