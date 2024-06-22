# Building Oneko for iOS

- Generate `resources.m`

```
./bundle.sh Resources/*.gif
```

- Build normally with Theos

```
THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1 make package
```