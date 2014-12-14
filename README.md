#EventLogView
本アプリケーションはSalesforce HackChallenge 2014のエントリーアプリです。

#概要
本アプリはForce.com上に蓄積されるEventLogFilesからログ情報を取得し、一覧表示、csvダウンロード、グラフで分析することができるアプリです。  
※EventLogFiles自体はWinter'15でGAとなったForce.comが提供する機能です  

#セットアップ
１．EventLogFilesが有効になったForce.com組織を用意してください（DEなど）  
２．src配下のメタデータを組織にデプロイします  
３．利用ユーザにEventLogViewの権限セットを与えます  

注意事項
・EventLogFilesは操作日の翌日のオフピーク時に作成されます。  
　サインアップしたばかりの組織の場合は、ログが1件も表示されないことがあります。  

#機能紹介
【一覧】  
・イベントタイプと日付範囲を選択して一覧表示  
・項目単位でのソート  
・csvダウンロード  

【分析】  
・Visualforce-画面別平均RUN_TIME  
・Visualforce-画面別平均VIEW_STATE  
・Visualforce-ページ利用数  
・API Method別カウント  
・レポート-利用数  
