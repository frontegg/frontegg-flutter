
<p align="center">
  <a href="https://www.frontegg.com/" rel="noopener" target="_blank">
    <img style="margin-top:40px" height="50" src="https://frontegg.com/wp-content/uploads/2020/04/logo_frrontegg.svg" alt="Frontegg logo">
  </a>
</p>
<h1 align="center">Frontegg-Flutter</h1>
<div align="center">

[Flutter Web](https://flutter.dev/web) pre-built Component for faster and simpler integration with Frontegg services.
</div>

## Installation
Frontegg-Flutter is available as an [pub.dev package](https://pub.dev/packages/frontegg).

#### 1. Add `frontegg` package to `pubspec.yaml` dependencies:
```yaml
 dependencies:
    frontegg:
```

#### Add script tag to the main HTML template file:
`[VERSION]` may be `latest`, `next` or specific versions. 
```html
 <body>
    <!-- set frontegg the first script -->
    <script src="https://assets.frontegg.com/admin-box/frontegg/[VERSION].js"></script>
    <!-- other scripts -->
 </body>
```


#### Initialize Frontegg App:

1. Use `setUrlStrategy(PathUrlStrategy());` to be able to work with frontegg routes
2. Edit main.dart file: 
    ```dart
    void main(){
    
      fronteggApp = initialize(FronteggOptions(
          version: 'next',
          contextOptions: ContextOptions(
              baseUrl: 'https://[HOST_NAME].frontegg.com',
              requestCredentials: 'include'
          )
      ));
    
      /**
       * wait for frontegg to be loaded and then runApp
       */
      
      fronteggApp.onLoad(allowInterop(() {
        runApp(MyApp());
      }));
    }
    ```
3. In order to observe to changes in Frontegg store: 
    ```dart
     fronteggApp.onStoreChanged(allowInterop((FronteggState state) {
        log(state.auth?.user?.email);
     }));
    ```
4. Add Frontegg routes as empty Container to the application router
    ```dart
      // ...
    
      return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
        '/overview': (context) => MyHomePage(title: 'TTTT'),
        
        /**
          * Below Frontegg Routes
          */
        '/account/login': (context) => Container(),
        '/account/logout': (context) => Container(),
        '/account/sign-up': (context) => Container(),
        '/account/activate': (context) => Container(),
        '/account/invitation/accept': (context) => Container(),
        '/account/forget-password': (context) => Container(),
        '/account/reset-password': (context) => Container(),
        '/account/social/success': (context) => Container()
      },
   
      // ... 
    ```


# License

This project is licensed under the terms of the [MIT license](/LICENSE).