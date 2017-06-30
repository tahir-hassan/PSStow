# PSStow

This PowerShell module provides the ability to stow away an item, and to then unstow that item.  By "stowing", we mean moving the item away for safekeeping, and then to unstow means to restore it to its original location.

In some networked environments, there is a size limit on your `USERPROFILE` directory.  You can keep its size down by stowing directories before you log off and then unstow these directories after you log in.

## Installation

### Install from PowerShellGallery (preferred)

You will need PowerShellGet.  It is included in Windows 10 and [WMF5](http://go.microsoft.com/fwlink/?LinkId=398175). If you are using PowerShell V3 or V4, you will need to install [PowerShellGet](https://www.microsoft.com/en-us/download/details.aspx?id=49186).

After installing PowerShellGet, you can simply run

```powershell
Install-Module PSStow -Scope CurrentUser
```

### Installing from GitHub

You can download the `PSStow` folder from this repository and copy it to one of your modules directory, using this Microsoft guide to [Installing a PowerShell Module][ms].

[ms]: https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx

## Usage

Both `Stow-Item` and `Unstow-Item` return  a `pscustomobject` with the properties:

* `Success` - can be either `true` or `false` depending on if it succeeded, or `null` if it can't be classified as either.
* `Item` - the path of the item being stowed or unstowed.
* `Store` - the (root) path of the store containing the stowed/unstowed item.
* `Message` - a message to help with diagnosing any issues that arise.

### Stowing a Directory

To stow a directory `C:\Users\<username>\.android` into a store `C:\_store`, use the `Stow-Item` function:

```powershell
Stow-Item -Path "$env:USERPROFILE\.android" -Store C:\_store
```

### Unstowing a directory

To unstow the stowed directory, you call `Unstow-Item` passing in the same arguments as you did to `Stow-Item`:

```powershell
Unstow-Item -Path "$env:USERPROFILE\.android" -Store C:\_store
```

## Advanced Usage

Typically there are a set of offending User Profile directories that are too large to be sent over the network as part of a roaming profile.  You can define two functions to deal with this situation:

* `stowUserProfileDirs` -  this will move massive directories out of `USERPROFILE` into `C:\_store`.
* `unstowUserProfileDirs` -  this will move the massive directories back for use.

```powershell
$global:stowStore =  "C:\_store";

$global:userProfileDirsToStow = @(
		"$env:LOCALAPPDATA\Google\Chrome\"                # Chrome dir settings
	, "$env:LOCALAPPDATA\Microsoft\VisualStudio\"      # Visual Studio settings (different versions)

	, "$env:USERPROFILE\.nuget\"                       # nuget cache
	, "$env:USERPROFILE\.android\"                     # visual studio's android files

	, "$env:LOCALAPPDATA\Microsoft\SQL Server Management Studio\" # SSMS settings (different versions)

	, "$env:LOCALAPPDATA\atom"                         # atom program dir

	, "$env:USERPROFILE\.atom\"                        # atom settings dir

	, "$env:LOCALAPPDATA\ApexSQL"                      # ApexSQL settings dir
);

Function stowUserProfileDirs {
	$global:userProfileDirsToStow | Stow-Item -Store $global:stowStore
}

Function unstowUserProfileDirs {
	$global:userProfileDirsToStow | Unstow-Item -Store $global:stowStore
}
```

You would put the above in your PowerShell profile, and when you log on you call `stowUserProfileDirs` and before you log off, you call `unstowUserProfileDirs`.

The alternative is to have `stowUserProfileDirs` to be called automatically on log on, and `unstowUserProfileDirs` called automatically before log off, which can be done using [Group Policy Editor][gpo].

[gpo]: https://technet.microsoft.com/en-us/library/cc725970(v=ws.11).aspx

## Licence

This project is under the MIT licence.
