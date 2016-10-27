# line-editor-gw

![image](image.png)

## 概要
- Gauche の line-editor サンプルを、Windows のコンソール用に改造したものです。  
  実行には Gauche v0.9.5 が必要です。  
  また、改造版のモジュールをいくつか使用しています。


## 実行方法
- line-editor-gw.bat をダブルクリック等で起動します。  
  (本サイトのファイル一式が同一フォルダに存在する必要があります)  
  あとは通常の Gauche の REPL と同じです。  
  (カーソル上下によるヒストリ機能や、Emacs ライクなキーバインドがいくつか、  
   使用可能になっています)  


## 変更点
- オリジナルからの変更点を以下に示します。

1. 入力のエコーではなく REPL として機能するように変更
2. 起動時の引数により、SJIS と UTF-8 の入出力に対応
3. モジュールの改造 (line-edit, console)
   - ワイド文字対応 (不完全)
   - 再表示関数 (redisplay) の処理変更
   - 複数行入力してカーソルを先頭に戻して Enter キーを押すと、  
     2行目以降がエコーバックに消される件の対策
   - 漢字を入力しようとして Alt+半角/全角キーを押すと終了する件の対策  
     (Alt+null キーにダミーコマンドを設定)
   - 端を越えてカーソル移動しようとするとマークが外れる件の対策
   - 複数行入力時のカーソル上下移動でマークが外れる件の対策
   - 複数行入力時の複数行のリージョン選択で、第2プロンプトも選択状態になる件の対策
   - Ctrl+l キーによる再表示で、表示が右にずれていく件の対策
   - Home/End キーを押すとエラーになる件の対策
   - 文字列の貼り付け (ペースト) の高速化
   - MS-IME が ON のときのスクロール表示の不具合対応
   - サロゲートペアの文字の入力に対応
   - カーソル位置取得 (query-cursor-position) の処理変更
   - ヒストリとキルリングのバッファについて、  
     あふれたときに古いものから消えるように暫定修正
4. MSYS2 の mintty 上での表示に暫定対応 (実験中)
5. MSYS2 の mintty 上で winpty 使用時の表示に暫定対応 (実験中)


## 注意事項
1. 1文字入力するごとに消去と再表示をしているため、入力文字数が多くなると、  
   ちらつきや遅延が発生します。
2. コマンドプロンプトで、バッファの最終行 (デフォルトでは300行) に文字を表示した  
   状態で、MS-IME を ON にすると、最終行に MS-IME の状態 (「全あ般ローマ」等) が  
   表示されて、全体の表示が1行上にスクロールします。  
   そして、このときに何か不具合が生じているらしく、さらに最終行に文字を表示すると、  
   表示が乱れたり、エラーが発生したりします。  
   この現象を回避するため、windows.scm に対策用のコードを入れています。  
   (1行余分にスクロールして最終行を空ける等。windows.scm の  
   ensure-bottom-room と cursor-down/scroll-up を参照)  
   しかし、まだ最終行に変な表示が残ったりするようです。  
   (MS-IME による日本語入力を使わなければ、本問題は発生しません)


## 要調査事項
1. mintty 上で、Ctrl+矢印キー 等で、変な文字が入力される。  
   → 保留 (割り当てを増やせば対応できそうだが。。。)
2. mintty 上で、矢印キーの上と Enter キーを交互に素早く押すと、「terminal error」が出る。  
   → 修正 (カーソル位置取得の処理を変更。ただし、現状、エスケープシーケンスの文字列が  
   表示されることがある)
3. mintty 上で、入力がエコーバックされたり、入力が消えたりする。  
   → 修正 (サンプルプログラム側で、メイン処理を call-with-console で囲って、常にエコーなし  
   にした。また、カーソル位置取得中に受信した文字を、捨てないでキューイングするようにした)  
   → 修正 (上記でエコーなしにしたため、REPL 上で read-line 等を実行すると、入力が見えなく  
   なった。このため、REPL の evaluator の実行時だけは、エコーありにした。  
   (結局、完全な対策にはなっていない。。。))
4. mintty 上で、画面サイズを超える複数行を入力すると、カーソル移動がおかしくなる。  
   → 完了 (画面表示のクリッピング処理を追加した)
5. カーソルの座標が、Windows コンソールではバッファの先頭が原点 (0,0) となっているが、  
   mintty では画面の左上が原点 (0,0) となっている。  
   → 保留 (これはどうにも。。。)


## 環境等
- OS
  - Windows 8.1 (64bit)
- 言語
  - Gauche v0.9.5
- ライセンス
  - オリジナルと同様とします

## 履歴
- 2015-11-23 v1.00 初版
- 2015-11-24 v1.01 コンソールバッファの最終行の処理修正(不完全)
- 2015-11-24 v1.02 一部処理見直し(redisplay)
- 2015-11-24 v1.03 改行入力時の第2プロンプト表示に対応
- 2015-11-27 v1.04 REPLのreaderの処理見直し
- 2015-12-4  v1.05 REPLでgauche.interactiveの機能を使用可能にした
- 2015-12-13 v1.06 文字列の貼り付け(ペースト)の高速化
- 2015-12-13 v1.07 行継続後の折り返し処理のバグ修正
- 2016-1-17  v1.08 コメント修正のみ
- 2016-2-27  v2.00 msjis以外の独自モジュールを削除して標準モジュールに変更
- 2016-2-27  v2.01 標準モジュールを改造(実験中)
- 2016-2-29  v2.02 Windowsコンソールでサロゲートペアの入力に対応。その他デバッグ等
- 2016-3-1   v2.03 デバッグ等
- 2016-3-1   v2.04 デバッグ等
- 2016-3-1   v2.05 デバッグ等
- 2016-3-2   v2.06 デバッグ等
- 2016-3-2   v2.07 デバッグ等
- 2016-3-4   v2.10 デバッグ等
- 2016-3-7   v2.20 termios の without-echoing の mintty 対応等
- 2016-3-9   v2.30 デバッグ等
- 2016-3-9   v2.40 デバッグ等
- 2016-3-10  v2.41 デバッグ等
- 2016-3-10  v2.42 標準モジュールの更新に追従(console.scm)
- 2016-3-10  v2.43 termios の cond-expand の else 抜け修正
- 2016-3-11  v2.50 標準モジュールの内容に差し替え(termios)
- 2016-3-11  v2.51 標準モジュールの更新に追従(console.scm)
- 2016-3-13  v2.60 標準モジュールの内容に差し替え(console)
- 2016-3-13  v2.61 標準モジュールの更新に追従(console.scm, windows.scm)
- 2016-3-15  v2.62 デバッグ等
- 2016-3-22  v2.70 標準モジュールの更新に追従(line-edit.scm)
- 2016-4-24  v2.71 line-editor-gw.scm の main の引数処理見直し
- 2016-5-24  v2.80 標準モジュールの更新に追従(console.scm, line-edit.scm)  
  windows.scm の set-character-attribute の reverse 処理修正  
  REPLの改行出力削除(line-edit.scm で出力するようになったため)
- 2016-5-26  v2.81 cursor-down/scroll-up の処理見直し等
- 2016-5-26  v2.82 cursor-down/scroll-up の処理見直し等
- 2016-5-27  v2.83 cursor-down/scroll-up の処理修正
- 2016-5-27  v2.84 一部処理見直し(redisplay)
- 2016-5-30  v2.85 REPLのEOF処理見直し
- 2016-10-27 v2.86 標準モジュールの更新に追従(console.scm)  
  ヒストリとキルリングのバッファがあふれたときの処理を暫定修正(line-edit.scm)


(2016-10-27)
