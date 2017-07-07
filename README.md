# Stormshade
## Custom Reshade build + shader preset for Final Fantasy 14.

[Stormshade](https://ffstormshade.wixsite.com/stormshade) is a custom Reshade build compiled using [reshade's](https://github.com/crosire/reshade) latest open source [files](https://github.com/crosire/reshade). It has an unlocked depth buffer that enables it to utilize some of reshade's amazing shaders that uses depth information to work in online games.

> Vanilla reshade disables/turns off shaders that uses depth information by default once it detects network activity. This is implemented by design to avoid being exploited and used to gain an advantage in competitive online games. The patched reshade build in this repo **will only work in Final Fantasy 14**.

## Quick Notes Before Installing
* **You don't need** to install **Reshade** for this to work.
* **Reshade** is basically just a dll file (it generates the proper dll files when you use reshade's application). I understand some of the skepticism when it comes to dll files. Feel free to scan it for your peace of mind. If you're really worried that I might infect your machine, **just don't install this at all**.
* This custom reshade build was **tested on DIRECTX11 client of the game ONLY**. Haven't tried it on DIRECTX9 yet.
* I created this to improve your experience of the game. It the current settings doesn't suit your taste, you are free to tinker with the files/settings and **make it your own**. I really don't mind.
* I made sure the installation of this build will be as easy to implement as possible, still, read the instructions carefully just to be on the safe side.

## Caveats
There's only one issue same with all other shader builds out there that utilizes ambient occlusion. Unfortunately, we can't do anything about it. I still did a couple of adjustments to make this issue as subtle as possible.

Reshade applies all shader effects on top of your game so ambient occlusion effects will also render on top of your game's windows. I did some adjustments to this making it less distracting. The adjustments works for me and I can still play the game normally. If it bothers you, then you will have to turn off the ambient occlusion settings (which is sad since it's one of the things that makes the game pretty).

![image1](http://i.imgur.com/x3Co8BN.jpg)

# Installation
* Clone or download this repo. (For first time github users, **there's a download button on the top right**).
* Download this repo as **zip**.
* Extract all the contents of this zip file inside your FF14 game directory: Your Installation Directory\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\game\.
