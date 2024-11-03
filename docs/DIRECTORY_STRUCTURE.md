# ディレクトリ構造

## ドキュメント関連 (/docs)

### 図表ディレクトリ (/docs/diagrams)

ECS_4/
├── README.md                   # プロジェクトの概要
└── docs/
    ├── DIRECTORY_STRUCTURE.md  # ディレクトリ構造の詳細な説明
    ├── DOCUMENTATION.md        # プロジェクトの詳細なドキュメント
    └── diagrams/              
        ├── mermaid/          
        │   ├── flow.mmd      
        │   └── er.mmd        
        └── images/           
            ├── flow.png      
            ├── flow.svg      
            ├── er.png        
            └── er.svg        

#### 説明

##### ディレクトリとファイルの説明
- `diagrams/`: 図表関連のファイルを格納するディレクトリ
  - `mermaid/`: Mermaidのソースファイル（.mmd）を格納
    - `flow.mmd`: システムのフロー図のソースコード
    - `er.mmd`: ERダイアグラムのソースコード
  - `images/`: ソースから生成された画像ファイルを格納
    - PNG形式: 一般的な表示用
    - SVG形式: 高品質な表示・編集用

##### バージョン管理について
- flowやerのバージョン管理はGitで行う
- 変更点はGitの履歴から確認する
