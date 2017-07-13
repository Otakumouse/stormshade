# Stormshade
## Custom Reshade build + shader preset for Final Fantasy 14.

[Stormshade](https://ffstormshade.wixsite.com/stormshade) is a custom Reshade build compiled using [reshade's](https://github.com/crosire/reshade) latest open source [files](https://github.com/crosire/reshade). It has an unlocked depth buffer that enables it to utilize some of reshade's amazing shaders that uses depth information to work in online games.

> Vanilla reshade disables/turns off shaders that uses depth information by default once it detects network activity. This is implemented by design to avoid being exploited and used to gain an advantage in competitive online games. The patched reshade build in this repo **will only work in Final Fantasy 14**.

## Quick Notes Before Installing
* **You don't need** to install **Reshade** for this to work.
* **Reshade** is basically just a dll file (it generates the proper dll files when you use reshade's application). I understand some of the skepticism when it comes to dll files. Feel free to scan it for your peace of mind. If you're really worried that I might infect your machine, **just don't install it**.
* This custom reshade build was **tested on DIRECTX11 client of the game ONLY**. Haven't tried it on DIRECTX9 yet.
* I created this to improve your experience of the game. If the current settings doesn't suit your taste, you are free to tinker with the files/settings and **make it your own**. I really don't mind.
* Make sure to use the correct preset based on your screen resolution **(1080, 1440, 4k .ini files)**.
* I made sure the installation of this build will be as easy to implement as possible, still, read the instructions carefully just to be on the safe side.
* **DO NOT** overwrite the default shaders included in this repo with the ones found in vanilla reshade. These are modified shaders from source which gives Stormshade its looks.

## Caveats
There's only one issue same with all other shader builds out there that utilizes ambient occlusion. Unfortunately, we can't do anything about it. I still did a couple of adjustments to make this issue as subtle as possible.

Reshade applies all shader effects on top of your game so ambient occlusion effects will also render on top of your game's windows. I did some adjustments to this making it less distracting. The adjustments works for me and I can still play the game normally. If it bothers you, then you will have to turn off the ambient occlusion settings (which is sad since it's one of the things that makes the game pretty).

![image1](http://i.imgur.com/x3Co8BN.jpg)

# Installation
* Clone or download this repo. (For first time github users, **there's a download button on the top right**).
* Download this repo as **zip**.
* Extract or drag all the contents of this zip file inside your FF14 game directory: Your Installation Directory\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\game\.
* Done. **Run  the game**.

# Shader Setup
I suggest login in inside the game first.Once you have all files in place. Hit **SHIFT + F2** to open reshade's in-game UI.

![image2](http://i.imgur.com/vyFFjLn.jpg)

**Stormshade is turned off by default**. To activate it, click on the drop down button to select the proper preset based on your screen resolution. There are 3 presets as of now designed for **1080p**, **1440p**, and **4k** respectively.

NOTE: You might experience having duplicated presets, just delete them by clicking the **minus** icon (if it bothers you).

![image3](http://i.imgur.com/JxExYX9.jpg)

**That's it!** Enjoy playing the game and use this as a base configuration if you want to make your own. Thanks for all the feedback and will update this repo once I have some solid improvements to add.

![image4](http://i.imgur.com/k0M2Jbj.jpg)

# Tips / Troubleshooting
* If text appear distorted or making you feel dizzy, press SHIFT+F2, look for **CA** on the list of effects and toggle it off.
* If you are not a fan of film grain, you can also reduce it's intensity or turn it off by using the same steps above. Look for the **Film Grain** effect on the list.
* If you notice the "Ambient Occlusion" bleeding underwater. Go to **SYSTEM CONFIG** > **GRAPHICS SETTINGS** and look for **WATER REFRACTION**. Turn that off (It doesn't add major effects underwater anyway :P)
* If your settings are not being saved whenever you restart the game. Make sure your FF14 game directory has the proper permissions setup. To check this, right click on your game folder, select **SECURITY** tab and click **EDIT** to update folder permissions.

# Optimization Tips (Squeeze those FPSes!!!)
* Turning off in-game HBAO+ will have a huge performance boost in your FPS. FF14's in-game HBAO+ is a taxing feature specially in "quality" mode.
* DO NOT USE **Fine Sharpen** in sharpening your scene if you don't have extra GPU horsepower. Use **Luma Sharpen** instead since it's much faster.
* One of the heavy hitters here is **MXAO** (or what they call HBAO+ on steroids). Try adjusting the "sample count" in the settings (SHIFT + F2) to find the perfect balance between performance/appearance.
