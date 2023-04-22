# QiitaSample
QiitaSampleはQiitaAPIとCombineフレームワークを用いたサンプルアプリです。投稿内容の概要をリスト表示し、タップすることで詳細な内容を表示します。  
## 導入
1. 下記のコマンドを任意のディレクトリから実行してださい。  
```  
$ git clone https://github.com/KenKato-Dev/QiitaSample  
$ cd QiitaSample    
```  
2. 移動したディレクトリにあるQiitaSample.xcodeprojを開いてください。  
3. Xcodeからアプリを実行してください。  
## 構成  

- MVVM  
- Combine
- API
    - Qiita API  
  
MVVM:  
設計パターンはMVVMを採用しています。構成としては各画面にViewControllerとViewModel、複数画面向けにModelを用意し、それぞれ以下の役割としています。  
- ViewContoller：ViewModelから返された値やイベントをもとに描画処理を実行  
- Presenter：ViewControllerに表示するデータの保持とViewControllerからの入力などのイベントを加工、ModelとViewControllerの仲介処理を行う  
- Model：純粋なドメインロジックやデータを持ち、ViewModel、ViewControllerに依存せず独立してAPIへのリクエストやデータベースへのアクセスなど単体にて実行  
  
Combine:  
Combineフレームワークを導入し、データバインディング機能と監視による非同期処理の簡易化を図っております。
  
Qiita API:
QIita APIを用いてQiitaに掲載された記事を取得しております。  
ドキュメント：https://qiita.com/api/v2/docs
  
## 工夫した点
Async/Await構文を用いた非同期処理：  
処理にAsync/Awaitを用いることで、同じ処理内容をCompletion handlerのResult型で記述した時よりも以下のメリットを感じております。
・記述量の減少
・シーケンシャルな処理順により内容を把握しやすい記述
・Do-Tryを活用いたエラーハンドルの簡易化など様々なメリットがある感じております。  
UITableViewDiffableDataSourceを用いたTableViewの表示:  
UITableViewDiffableDataSourceはこれまで使用していたデリゲートメソッドに準じた関数より記述削減に加えて、査読更新によるパフォーマンス向上を期待して使用しております。  
ページネーション機能：  
APIのResponseに正規表現としてページ情報が返されるため、情報を取り出して使用しております。アプリ起動時や画面遷移時の待機時間減少を期待しております。

