import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:new_riverpod/custom_theme.dart';
import 'package:new_riverpod/screen/setting_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appBarTitleProvider = Provider<String>((_) => 'AppBarTitle');
final counterProvider =
    StateNotifierProvider<CounterNotifier, int>((_) => CounterNotifier());

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void addOne() => state++;
}

// SharedPreferencesのプロバイダー
// オーバーライドで値を上書きするので、定義時は例外を投げておく
// インスタンスを取得する関数は非同期なのでFeatureProviderで定義する必要があることと、
// 保存した値を読み込むgetメソッドを使う時に、非同期ではない処理なのにFutureで定義しなくてはならなくなる
final sharedPreferencesProvider =
    Provider<SharedPreferences>((_) => throw UnimplementedError());

void main() async {
  final flavor = Flavor.production;
  print(flavor.name);
  // 非同期処理をする時に必要
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // sharedPreferencesProviderの値をインスタンスで上書きする
    // 例外が入っているプロバイダーをオーバーライドすることで一度だけの取得で済む
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ref.watch(themeSelectorProvider),
      home: const SettingThemeScreen(),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initStateの代替コード。
    useEffect(() {
      debugPrint('useEffect 実行');
      return null;
    }, const []);
    final _appBarTitle = ref.watch(appBarTitleProvider);
    final _counter = ref.watch(counterProvider);
    final _isAbove10 =
        ref.watch(counterProvider.select((value) => value >= 10));
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_counter.toString()),
          _isAbove10
              ? Container(
                  height: 100,
                  width: 100,
                  child: const Text('10以上なので表示'),
                  color: Colors.amber,
                )
              : const SizedBox(),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).addOne(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
