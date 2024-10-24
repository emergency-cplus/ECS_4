# Emergency Call Support

Emergency Call Supportは、119番通報時の指令員（オペレーター）の業務を支援し、通報者への指導をより効果的に行うためのWebアプリケーションです。

🌟 [アプリページ](https://ecs-4.fly.dev/)

## サービス概要

- 事前に準備された説明動画をSMSで送信
- 通報者の理解度向上と迅速な対応をサポート
- 指令員の業務効率化を実現

## 主な機能

- 状況別の説明動画ライブラリ
- ワンクリックでのSMS送信機能
- 送信履歴の管理
- 検索・フィルタリング機能
- ユーザー管理システム

## 画面遷移図

システムの画面遷移は以下通りです：

```mermaid
flowchart TD
  A["Create(users)"] --> B[Login]
  B --> C[Top]
  C <--> D[message_template]
  C <--> E[items_index]
  E --> F["select item"]
  F --> G{"Send item?"}
  G -->|Yes| H["send_form (PopUp)"]
  H -->|OK| I["send confirm"]
  H -->|Cancel| E
  G -->|NG| E
  E <--> J[send_lists]
  E --> K["show_item"]
  K --> L["edit_item"]
  L --> K
  K --> M["delete_item"]
  M --> E
  E <--> N["create_items"]
  
  %% 新しい要素
  C <--> O[User Management]
  E <--> P[Search/Filter]
  I --> Q[SMS Sent via Twilio]
 Q --> R[View Send History]
 R --> J
```

[詳細画面遷移図（Figma）](https://www.figma.com/file/b2eg08fgpCZsViWha4ok0T/Emergency_Call_Support(Flow-Diagram)?type=whiteboard&node-id=0%3A1&t=87TxCsT2z5kEfRZS-1)

## ER図

システムのデータベース構造を表すER図は以下の通りです：


```mermaid
erDiagram
    Users ||--o{ Items : posts
    Users ||--o{ SendLists : creates
    Items ||--o{ SendLists : is_sent_as
    Items ||--o{ Taggings : has
    Tags ||--o{ Taggings : has

    Users {
        bigint id PK
        string email UK "null: false"
        string crypted_password
        string salt
        string name "null: false"
        text message_template
        string token UK
        string reset_password_token
        datetime reset_password_token_expires_at
        datetime reset_password_email_sent_at
        string uuid UK "null: false"
        integer role
        datetime created_at
        datetime updated_at
    }

    Items {
        bigint id PK
        string title
        text description
        string item_url
        bigint user_id FK
        datetime created_at
        datetime updated_at
    }

    SendLists {
        bigint id PK
        bigint item_id FK
        bigint user_id FK "null: false"
        string phone_number
        datetime send_at
        string sender
        boolean send_as_test "default: false"
        datetime created_at
        datetime updated_at
    }

    Tags {
        bigint id PK
        string name UK
        integer taggings_count "default: 0"
        datetime created_at
        datetime updated_at
    }

    Taggings {
        bigint id PK
        bigint tag_id FK
        string taggable_type
        bigint taggable_id
        string tagger_type
        bigint tagger_id
        string context "limit: 128"
        string tenant "limit: 128"
        datetime created_at
    }
```

## 技術スタック

- フロントエンド: HTML, CSS, JavaScript, TailwindCSS
- バックエンド: Ruby on Rails, Node.js
- データベース: PostgreSQL
- インフラ: Docker
- デプロイ: Fly.io
- SMS送信: Twilio API

## 開発背景

現役消防士である開発者が、日々の119番通報対応業務の中で感じた課題を解決するために考案しました。音声のみによる説明での不安や誤解を解消し、より効果的な初期対応を実現することを目指しています。

🧑‍🚒 [開発者X](https://x.com/EmergencyCplus)

📺 [YouTubeチャンネル](https://www.youtube.com/@emegency_cplus "YouTube EmergenCy+")

応急手当て等のショート動画は↑チャンネルから（随時更新予定）

## 導入効果

- 通報者への的確な指示による救命率の向上
- 指令員の負担軽減と対応時間の短縮
- 標準化された指導による均一なサービス提供

## お問い合わせ

Emergency Call Supportの導入やデモンストレーションについてのお問い合わせは、以下のGoogleフォームからお願いいたします。

[お問い合わせフォーム](https://forms.gle/WoPsBfeCWghTMHAh9)
