![snapkit-sample-ios](https://user-images.githubusercontent.com/17683316/42133453-51ae48ea-7d65-11e8-980c-3a93026255d2.png)

This is an **unofficial** demo app of Snap Kit SDK produced by SnapChat for iOS Swift

## Documentation
* [Snapchat Snap Kit Official Documentation](https://docs.snapchat.com/docs)
* [Snapcat Snap Kit DIY Docs](https://github.com/bbookman/Snapchat-Snap-Kit-DIY-Docs)
* [Cocoapods](https://guides.cocoapods.org/using/getting-started.html)

## Instructions

These instructions assume a basic knowlege of Swift and Cocoapods

### Get a Snapchat Developer Account

1. Sign up for an account on the [Snapchat Dev Portal](https://kit.snapchat.com/)
2. Note / copy the value in **Development App Info** > **OAUTH2 CLIENT ID**
3. Enter the [iOS Bundle ID](https://cocoacasts.com/what-are-app-ids-and-bundle-identifiers/) for your app in **Development App Info** > **IOS BUNDLE ID** > _Add Your id here ..._
4. Under **Redirect URLs** enter a unique URL.  For example, you might choose the name of your app and a path.  
  * The key is that this be unique, but can be "made up" as long as the value you enter here is also the value you place in the Info.plist as described below.  
  * Example URL: **_myuniqueapp://somepath_**
  * Make note of the value you choose

### Snap Kit SDK

1. Open your Podfile and add

```ruby
pod 'SnapSDK', :subspecs => ['SCSDKLoginKit', 'SCSDKCreativeKit', 'SCSDKBitmojiKit']
```
2. pod install

### Edit Properties List
1. Right click on the Info.plist file in Xcode and choose Open As > Source Code
2. The string value for **SCSDKClientId** is the OATH2 CLIENT ID you noted from step 2 in **"Get a Snapchat Developer Account"**

```xml
<key>SCSDKClientId</key>
    <string>OAUTH2 CLIENT ID</string> 
```

3. The string value for **CFBundleURLSchemes** is the first portion of the Redirect URL.  So if the Redirect URL from step 4 in **"Get a Snapchat Developer Account"** was _myuniqueapp_://somepath, the value would be myuniqueapp

```xml
<array>
	<dict>
		<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string><insert your own value here></string>
			</array>
	</dict>
</array>
```

4. The **LSApplicationQueriesSchemes** would also need to be added to a new Info.plist, but it has **already** been added to this repository's plist

```xml
<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>itms-apps</string>
		<string>snapchat</string>
		<string>bitmoji-sdk</string>
	</array>
```    

## Login Kit
<img src="https://user-images.githubusercontent.com/17683316/42131965-12afd184-7d49-11e8-931b-0ef5578157df.png" width="100">

Anyplace you need the Login Kit code

```swift
import SCSDKLoginKit
```

### AppDelegate

This code needs to be added in the AppDelegate.swift file.  It has already been added to this sample app

```swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return SCSDKLoginClient.application(app, open: url, options: options)
    }
```

### Snapchat Official Login Button

```swift
let loginButton = SCSDKLoginButton()
```

### Other Login Button

```swift
@IBAction func loginButtonTapped(_ sender: Any) {
    SCSDKLoginClient.login(from: self, completion: { success, error in

        if let error = error {
            print(error.localizedDescription)
            return
        }

        if success {
            self.fetchSnapUserInfo() //used in the demo app to get user info
        }
    })
}
```

### Get User Data

Snapchat does not gather much data from users:
* User ID (A Snapchat internal generated value)
* Display Name (User's chosen display name)
* Bitmoji (Avatar, if user has created one)

Notice there is no ability to gather email address or real name.

The code below is one of many approches to parsing the values returned from SDSDKLoginClient.fetchUserData

```swift
private func fetchSnapUserInfo(){
    let graphQLQuery = "{me{displayName, bitmoji{avatar}}}"

    SCSDKLoginClient
        .fetchUserData(
            withQuery: graphQLQuery,
            variables: nil,
            success: { userInfo in

                if let userInfo = userInfo,
                    let data = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted),
                    let userEntity = try? JSONDecoder().decode(UserEntity.self, from: data) {

                    DispatchQueue.main.async {
                        self.goToLoginConfirm(userEntity)
                    }
                }
        }) { (error, isUserLoggedOut) in
            print(error?.localizedDescription ?? "")
    }
}
```

## Creative Kit
<img src="https://user-images.githubusercontent.com/17683316/42131997-9b7b3b8e-7d49-11e8-9651-092cf14fed1e.png" width="100">

Following this document https://docs.snapchat.com/docs/creative-kit/

You can share a photo or video attaching a sticker, url, and caption.

<img src="https://user-images.githubusercontent.com/17683316/42210546-402b855a-7eec-11e8-91f1-4c04e3242113.gif" width="250">

### Sample Code

```swift
import SCSDKCreativeKit

let snapshot = sceneView.snapshot() // Any image is OK. In this codes, SceneView's snapshot is passed.
let photo = SCSDKSnapPhoto(image: snapshot)
let snap = SCSDKPhotoSnapContent(snapPhoto: photo)

// Sticker
let sticker = SCSDKSnapSticker(stickerImage: #imageLiteral(resourceName: "snap-ghost"))
snap.sticker = sticker

// Caption
snap.caption = "Snap on Snapchat!"

// URL
snap.attachmentUrl = "https://www.snapchat.com"

let api = SCSDKSnapAPI(content: snap)
api.startSnapping { error in

    if let error = error {
        print(error.localizedDescription)
    } else {
        // success

    }
}
```

If you use `SCSDKVideoSnapContent`, you can share the videos.

## Bitmoji Kit
<img src="https://user-images.githubusercontent.com/17683316/42131995-9914d864-7d49-11e8-95de-f8c053b2f706.png" width="100">

### Fetch avatar image

You can fetch your avatar image by coding like below codes.

```swift
import SCSDKBitmojiKit

// fetch your avatar image.
SCSDKBitmojiClient.fetchAvatarURL { (avatarURL: String?, error: Error?) in
    DispatchQueue.main.async {
        if let avatarURL = avatarURL {
            self.iconView.load(from: avatarURL)
        }
    }
}
```

### Show bitmoji pickerview

The SCSDKBitmojiStickerPickerViewController is prepared in SCSDKBitmojiKit.

You can add the picker view as child viewController. It's very easy.

```swift
@IBAction func bitmojiButtonTapped(_ sender: Any) {
    // Make bitmoji background view
    let viewHeight: CGFloat = 300
    let screen: CGRect = UIScreen.main.bounds
    let backgroundView = UIView(
        frame: CGRect(
            x: 0,
            y: screen.height - viewHeight,
            width: screen.width,
            height: viewHeight
        )
    )
    view.addSubview(backgroundView)
    bitmojiSelectionView = backgroundView

    // add child ViewController
    let stickerPickerVC = SCSDKBitmojiStickerPickerViewController()
    stickerPickerVC.delegate = self
    addChildViewController(stickerPickerVC)
    backgroundView.addSubview(stickerPickerVC.view)
    stickerPickerVC.didMove(toParentViewController: self)
}
```

### Inherit SCSDKBitmojiStickerPickerViewControllerDelegate

If you Inherit SCSDKBitmojiStickerPickerViewControllerDelegate, you can track events when the piker is selected, and the serach field is focused.

In this demo codes, it makes the AR stamps by the URL of bitmoji and place to the sceneView.

```swift
extension CameraViewController: SCSDKBitmojiStickerPickerViewControllerDelegate {

    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController, didSelectBitmojiWithURL bitmojiURL: String) {

        bitmojiSelectionView?.removeFromSuperview()

        if let image = UIImage.load(from: bitmojiURL) {
            DispatchQueue.main.async {
                self.setImageToScene(image: image)
            }
        }
    }

    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController, searchFieldFocusDidChangeWithFocus hasFocus: Bool) {

    }
}
```

<img src="https://user-images.githubusercontent.com/17683316/42438970-8c02222c-839c-11e8-8ccb-5b0d266aa02a.gif" width="250">

## Reference
- https://kit.snapchat.com/
- https://storage.googleapis.com/snap-inc/brand-guidelines/snapchat-brand-standards.pdf
