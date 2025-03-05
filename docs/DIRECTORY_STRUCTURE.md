# ディレクトリ構造

```
ECS_4/
├── README.md                   # プロジェクトの概要、機能説明、スクリーンショット
└── docs/                       # ドキュメント関連
    ├── DIRECTORY_STRUCTURE.md  # 本ファイル：ディレクトリ構造の説明
    ├── DOCUMENTATION.md        # システム仕様、ER図、画面遷移図等の技術文書
    └── diagrams/               # 図表関連ファイル
        ├── mermaid/            # 図表のソースコード
        │   ├── flow.mmd        # 画面遷移図のソース
        │   └── er.mmd          # ER図のソース
        └── images/             # 生成された図表画像
            ├── flow.png        # 画面遷移図（DOCUMENTATION.mdで使用）
            └── er.png          # ER図（DOCUMENTATION.mdで使用）
```

### トップレベル
- `README.md`: プロジェクトのメインドキュメント
  - サービス概要
  - 主な機能
  - スクリーンショット
  - 開発背景
  - 連絡先情報

### docs/
- `DOCUMENTATION.md`: 技術文書
  - システム仕様
  - 画面遷移図
  - ER図
  - 技術スタック
- `diagrams/`: 設計図関連
  - `mermaid/`: [Mermaid.js](https://mermaid.js.org/)形式のソースファイル
  - `images/`: PNG/SVG形式の生成済み画像

## バージョン管理

- すべてのファイルはGitで管理
- 図表の更新時は、ソース（.mmd）と生成物（.png）の両方をコミット
- 変更履歴はGitログを参照

## 関連リンク

- [アプリケーション](https://ecs-4.fly.dev/)
- [画面遷移図（Figma）](https://www.figma.com/file/b2eg08fgpCZsViWha4ok0T/)

