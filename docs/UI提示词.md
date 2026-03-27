# 旅行轨迹记录 APP - UI设计提示词

> 用于AI生成UI设计图的提示词

---

## 设计风格指南

### 整体风格
- **风格定位**：清新、现代、旅行感
- **主色调**：蓝色系（天空/旅行）+ 绿色点缀（自然/探索）
- **辅助色**：橙色（活力/标记）、灰色（文字/分割）
- **圆角**：大圆角（12-16px），亲和感
- **字体**：无衬线，清晰易读
- **图标**：线性图标，简洁

### 色彩规范
```
主色：#2196F3（蓝色）
辅助色：#4CAF50（绿色）
强调色：#FF9800（橙色）
背景色：#F5F5F5（浅灰）
卡片背景：#FFFFFF（白色）
主文字：#212121（深灰）
次文字：#757575（中灰）
分割线：#E0E0E0
```

---

## 核心页面UI提示词

### 1. 首页

**页面描述：**
旅行轨迹记录APP的首页，简洁明了，突出当前行程状态和核心操作入口。

**布局结构：**
```
┌─────────────────────────────────────┐
│          顶部状态栏                  │
│  APP名称 + 当前行程标签              │
├─────────────────────────────────────┤
│                                     │
│       地图预览区域                   │
│    （占屏幕40%高度）                 │
│    - 当前位置蓝点                   │
│    - 附近打卡点标记                 │
│    - 圆角卡片样式                   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  当前行程卡片（白色卡片，阴影）      │
│  ┌─────────────────────────────────┐│
│  │ 🗓️ 西藏十日游                    ││
│  │ 3/15 - 3/24 | 第3天 | 📍西藏     ││
│  │                                 ││
│  │ 今日：轨迹 12.5km | 打卡 3个    ││
│  └─────────────────────────────────┘│
│                                     │
│  核心操作按钮（两个大按钮）          │
│  ┌─────────────────────────────────┐│
│  │  [📍 记录]       [✨ 打卡]      ││
│  │   持续采集       离散记录        ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  底部导航栏                          │
│  [行程列表] [同步] [设置]            │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a mobile app home screen for a travel tracking app with:

1. TOP AREA:
   - App name "轨迹记录" on the left
   - Current trip status badge on the right (e.g., "第3天")

2. MAP PREVIEW (40% of screen height):
   - Rounded corners (16px)
   - Show current location with blue dot
   - Show nearby check-in points as orange markers
   - Light shadow beneath the map card

3. CURRENT TRIP CARD (white card with shadow):
   - Trip name: "西藏十日游" (large, bold)
   - Date range: "3/15 - 3/24"
   - Current day: "第3天"
   - Destination icons: "📍西藏、云南"
   - Today's stats: "轨迹 12.5km | 打卡 3个"

4. ACTION BUTTONS (two large buttons side by side):
   - LEFT: Blue button "📍 记录" with subtitle "持续采集"
   - RIGHT: Orange button "✨ 打卡" with subtitle "离散记录"
   - Both buttons: rounded, bold text, icon + text

5. BOTTOM NAVIGATION:
   - Three icons with labels: 行程列表, 同步, 设置
   - Clean, minimal design

COLORS:
- Primary: #2196F3 (blue)
- Accent: #FF9800 (orange)
- Background: #F5F5F5
- Cards: #FFFFFF with subtle shadow

STYLE:
- Modern, clean, travel-themed
- Large touch targets
- Ample white space
- Rounded corners throughout
```

---

### 2. 创建行程页

**页面描述：**
创建新旅行的表单页面，包含行程名称、日期选择、目的地多选。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 创建行程                          │
├─────────────────────────────────────┤
│                                     │
│  行程名称 *                          │
│  ┌─────────────────────────────────┐│
│  │ 西藏十日游                       ││
│  └─────────────────────────────────┘│
│                                     │
│  开始日期 *          结束日期 *      │
│  ┌──────────────┐  ┌──────────────┐│
│  │ 📅 3月15日   │  │ 📅 3月24日   ││
│  └──────────────┘  └──────────────┘│
│                                     │
│  行程天数                            │
│  ┌─────────────────────────────────┐│
│  │           10 天                  ││
│  └─────────────────────────────────┘│
│                                     │
│  目的地 * (可多选)                   │
│  ┌─────────────────────────────────┐│
│  │ [国内]  [国外]                  ││
│  └─────────────────────────────────┘│
│                                     │
│  已选择: 西藏、云南                   │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 省份网格 (3列)                   ││
│  │                                 ││
│  │ ○ 北京  ○ 上海  ● 西藏          ││
│  │ ● 云南  ○ 四川  ○ 新疆          ││
│  │ ○ 海南  ○ 广东  ○ 浙江          ││
│  │ ...                             ││
│  └─────────────────────────────────┘│
│                                     │
│         [ ✈️ 创建行程 ]             │
│         (大按钮，固定底部)           │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a create trip form screen with:

1. HEADER:
   - Back button "←" on the left
   - Title "创建行程" centered

2. FORM FIELDS:
   - Trip name input (text field with placeholder "输入行程名称")
   - Date range picker: two date fields side by side
     - Left: "开始日期" with calendar icon
     - Right: "结束日期" with calendar icon
   - Auto-calculated trip duration: "10 天" displayed prominently

3. DESTINATION SELECTOR:
   - Toggle: [国内] [国外] tabs
   - Selected destinations shown as chips/tags: "西藏 ×" "云南 ×"
   - Province/country grid (3 columns):
     - Unselected: circle outline
     - Selected: filled circle with checkmark
     - Text label below each item

4. CREATE BUTTON:
   - Fixed at bottom
   - Full width
   - Blue background (#2196F3)
   - White text "✈️ 创建行程"
   - Large, prominent

STYLE:
- Clean form design
- Clear visual hierarchy
- Required fields marked with asterisk (*)
- Helpful tooltips
- Smooth transitions
```

---

### 3. 记录页（持续记录）

**页面描述：**
持续记录旅行轨迹的页面，显示实时地图、运动数据、控制按钮。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 记录中    00:23:45      [⏸ 暂停] │
├─────────────────────────────────────┤
│                                     │
│       全屏地图区域                   │
│    （占屏幕65%高度）                 │
│    - 实时轨迹线（蓝色粗线）          │
│    - 当前位置蓝点（脉冲动画）        │
│    - 地图跟随当前位置                │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  数据面板（半透明黑色背景）          │
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │   📍 5.2 km      ⏱️ 23:45      ││
│  │   (大字号，居中显示)             ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  控制按钮                            │
│  ┌─────────────┐  ┌─────────────┐  │
│  │  ⏸ 暂停     │  │  ⏹ 结束     │  │
│  │  (橙色)     │  │  (红色)     │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design an active recording screen for travel tracking:

1. HEADER:
   - Back button "←" on the left
   - Timer "00:23:45" centered (large, monospace font)
   - "⏸ 暂停" button on the right

2. FULL SCREEN MAP (65% of screen):
   - Shows current trajectory as blue thick line
   - Current location as pulsing blue dot
   - Map auto-follows current position
   - Minimal UI overlay

3. DATA PANEL (semi-transparent dark background):
   - Floating panel at bottom of map
   - Two metrics side by side:
     - Left: "📍 5.2 km" (distance)
     - Right: "⏱️ 23:45" (duration)
   - Large, bold, white text
   - Rounded corners

4. CONTROL BUTTONS (below map):
   - Two buttons side by side:
     - LEFT: "⏸ 暂停" (orange #FF9800)
     - RIGHT: "⏹ 结束" (red #F44336)
   - Large buttons, easy to tap
   - Clear visual distinction

STYLE:
- Immersive map experience
- High contrast for outdoor visibility
- Minimal distractions
- Clear status indicators
```

---

### 4. 打卡页

**页面描述：**
手动打卡页面，显示当前位置、地图、可填写地点名称和备注。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 打卡                              │
├─────────────────────────────────────┤
│                                     │
│       地图区域                       │
│    （占屏幕40%高度）                 │
│    - 当前位置蓝点                   │
│    - 圆角卡片样式                   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  当前位置                            │
│  拉萨市城关区北京东路35号            │
│  (灰色小字)                          │
│                                     │
│  地点名称 (可选)                     │
│  ┌─────────────────────────────────┐│
│  │ 布达拉宫                         ││
│  └─────────────────────────────────┘│
│                                     │
│  备注 (可选)                         │
│  ┌─────────────────────────────────┐│
│  │ 终于到了布达拉宫！               ││
│  │                                 ││
│  └─────────────────────────────────┘│
│  (多行文本框)                        │
│                                     │
│         [ ✨ 确认打卡 ]             │
│         (大按钮，固定底部)           │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a check-in form screen:

1. HEADER:
   - Back button "←" on the left
   - Title "打卡" centered

2. MAP PREVIEW (40% of screen):
   - Shows current location
   - Blue dot marker
   - Rounded corners

3. LOCATION INFO:
   - Label: "当前位置" (small, gray)
   - Address: "拉萨市城关区北京东路35号"
   - Auto-detected, shown prominently

4. FORM FIELDS:
   - Place name (optional):
     - Single line text input
     - Placeholder: "添加地点名称"
   - Note (optional):
     - Multi-line text area (3-4 lines)
     - Placeholder: "记录此刻心情..."

5. CHECK-IN BUTTON:
   - Fixed at bottom
   - Full width
   - Orange background (#FF9800)
   - White text "✨ 确认打卡"
   - Large, prominent

STYLE:
- Simple, focused interface
- Optional fields clearly marked
- Encouraging tone
- Quick to complete
```

---

### 5. 行程详情页

**页面描述：**
展示单个行程的完整信息，包括地图、统计数据、每日行程列表入口。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 西藏十日游              [编辑]   │
├─────────────────────────────────────┤
│                                     │
│       行程地图区域                   │
│    （占屏幕50%高度）                 │
│    - 完整轨迹线                     │
│    - 所有打卡点标记                 │
│    - 可缩放、拖动                   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📅 2026/3/15 - 3/24  共10天        │
│  📍 西藏、云南                       │
│                                     │
│  📊 行程统计（三个数字卡片）         │
│  ┌──────────┬──────────┬──────────┐│
│  │ 轨迹段   │ 打卡点   │ 总里程   ││
│  │   15     │   32     │ 856km    ││
│  └──────────┴──────────┴──────────┘│
│                                     │
│  快捷操作                            │
│  ┌─────────────────────────────────┐│
│  │ [📅 每日行程]  [📷 导入照片]    ││
│  │ [📤 导出轨迹]  [⚡ 异常处理]    ││
│  └─────────────────────────────────┘│
│  (2x2网格按钮)                       │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a trip detail screen:

1. HEADER:
   - Back button "←" on the left
   - Trip name "西藏十日游" centered
   - "编辑" button on the right

2. TRIP MAP (50% of screen):
   - Shows complete trajectory
   - All check-in points as markers
   - Different colors for different types (auto/manual/photo)
   - Interactive (zoom, pan)

3. TRIP INFO:
   - Date range: "📅 2026/3/15 - 3/24  共10天"
   - Destinations: "📍 西藏、云南"

4. STATS CARDS (3 cards in a row):
   - Card 1: "轨迹段" with number "15"
   - Card 2: "打卡点" with number "32"
   - Card 3: "总里程" with number "856km"
   - Each card: white background, icon, label, large number

5. ACTION BUTTONS (2x2 grid):
   - Row 1: [📅 每日行程] [📷 导入照片]
   - Row 2: [📤 导出轨迹] [⚡ 异常处理]
   - Each button: icon + text, rounded corners

STYLE:
- Information-rich but organized
- Clear visual hierarchy
- Easy access to key actions
- Beautiful map visualization
```

---

### 6. 每日行程列表页

**页面描述：**
展示行程每一天的详细数据列表，支持查看详情和导出单天轨迹。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 西藏十日游 - 每日行程             │
├─────────────────────────────────────┤
│                                     │
│  📅 2026年3月15日 - 3月24日          │
│  (日期范围，顶部固定)                │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 第1天 · 3月15日 · 周六          ││
│  │ 📍 拉萨                         ││
│  │ ━━━ 轨迹 12.5km  ⚪ 打卡 5个    ││
│  │                                 ││
│  │ [查看详情] [📷 导入] [📤 导出]  ││
│  └─────────────────────────────────┘│
│  (白色卡片，阴影，可滑动)            │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 第2天 · 3月16日 · 周日          ││
│  │ 📍 拉萨                         ││
│  │ ━━━ 轨迹 8.3km   ⚪ 打卡 3个    ││
│  │                                 ││
│  │ [查看详情] [📷 导入] [📤 导出]  ││
│  └─────────────────────────────────┘│
│                                     │
│  · · · (更多天)                      │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 📊 行程总计                      ││
│  │ 轨迹 856km  打卡 32个  10天      ││
│  │                                 ││
│  │ [📤 导出全程轨迹图]             ││
│  └─────────────────────────────────┘│
│  (固定底部)                          │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a daily trip list screen:

1. HEADER:
   - Back button "←" on the left
   - Title "西藏十日游 - 每日行程" centered

2. DATE RANGE (sticky below header):
   - "📅 2026年3月15日 - 3月24日"
   - Light background

3. DAY CARDS (scrollable list):
   Each card contains:
   - Day number and date: "第1天 · 3月15日 · 周六"
   - Location: "📍 拉萨"
   - Stats: "━━━ 轨迹 12.5km  ⚪ 打卡 5个"
   - Actions: Three small buttons
     - [查看详情] (blue text)
     - [📷 导入] (gray text)
     - [📤 导出] (gray text)

4. SUMMARY CARD (fixed at bottom):
   - "📊 行程总计"
   - Three stats: "轨迹 856km  打卡 32个  10天"
   - Large button: "📤 导出全程轨迹图"

STYLE:
- Card-based layout
- Each card clearly separated
- Easy to scan
- Quick actions accessible
```

---

### 7. 导入照片页

**页面描述：**
从相册导入照片补全行程，显示扫描结果、待导入列表、异常照片。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 导入照片 - 第3天 · 3月17日        │
├─────────────────────────────────────┤
│                                     │
│  📅 选择照片日期范围                  │
│  ┌─────────┐    ┌─────────┐        │
│  │ 3/17    │ →  │ 3/17    │        │
│  └─────────┘    └─────────┘        │
│                                     │
│  📊 扫描结果                         │
│  ┌─────────────────────────────────┐│
│  │ 找到 23 张照片                   ││
│  │ ├─ ✓ 有定位信息: 18 张          ││
│  │ ├─ - 无定位信息: 3 张           ││
│  │ └─ ⚠ 异常定位: 2 张 (已排除)    ││
│  └─────────────────────────────────┘│
│                                     │
│  📷 待导入照片 (18张)                │
│  ┌─────────────────────────────────┐│
│  │ 照片网格 (3列)                   ││
│  │                                 ││
│  │ ☑️ [缩略图]  ☑️ [缩略图]  ☑️ [缩略图]│
│  │   10:30         10:45         12:30│
│  │                                 ││
│  │ ☑️ [缩略图]  ☑️ [缩略图]  ☑️ [缩略图]│
│  │   14:00         16:30         18:00│
│  └─────────────────────────────────┘│
│                                     │
│  ⚠️ 已排除 (异常定位)                │
│  ┌─────────────────────────────────┐│
│  │ ⬜ [缩略图]  ⬜ [缩略图]         ││
│  │   广州         北京              ││
│  │ (不在行程目的地)                 ││
│  └─────────────────────────────────┘│
│                                     │
│  [取消]           [导入 18 张]       │
│  (两个按钮，固定底部)                │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a photo import screen:

1. HEADER:
   - Back button "←" on the left
   - Title "导入照片 - 第3天 · 3月17日" centered

2. DATE RANGE SELECTOR:
   - Two date pickers side by side with arrow between
   - Simple, clean design

3. SCAN RESULTS:
   - Summary card showing:
     - Total photos found: "找到 23 张照片"
     - With location: "✓ 有定位信息: 18 张" (green)
     - Without location: "- 无定位信息: 3 张" (gray)
     - Anomaly: "⚠ 异常定位: 2 张 (已排除)" (orange)

4. PHOTO GRID (main area, scrollable):
   - 3-column grid of photo thumbnails
   - Each photo shows:
     - Checkbox (checked by default)
     - Thumbnail image
     - Time stamp below
   - Selected photos have blue border

5. EXCLUDED PHOTOS SECTION:
   - Gray/dimmed background
   - "⚠️ 已排除 (异常定位)" header
   - Smaller thumbnails
   - Reason shown below each (e.g., "广州 (不在行程目的地)")
   - Not selectable

6. ACTION BUTTONS (fixed at bottom):
   - LEFT: "取消" (gray, secondary)
   - RIGHT: "导入 18 张" (blue, primary)

STYLE:
- Photo-centric design
- Clear status indicators
- Easy batch selection
- Helpful filtering feedback
```

---

### 8. 运动方式选择弹窗

**页面描述：**
开始持续记录时选择运动方式的弹窗。

**布局结构：**
```
┌─────────────────────────────────────┐
│                                     │
│          开始记录                    │
│                                     │
│  选择运动方式：                      │
│                                     │
│  ┌─────────────────────────────────┐│
│  │  🚗 自驾（默认）                 ││
│  │     适合公路旅行、城市间移动      ││
│  │     [蓝色边框，已选中]           ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │  🚴 骑行                        ││
│  │     适合骑行游览、环湖骑行        ││
│  │     [灰色边框]                   ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │  🚶 步行                        ││
│  │     适合城市漫步、景区游玩        ││
│  │     [灰色边框]                   ││
│  └─────────────────────────────────┘│
│                                     │
│         [ 开始记录 ]                │
│         (大按钮)                    │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a mode selection modal/bottom sheet:

1. HEADER:
   - Title "开始记录" (large, centered)

2. MODE SELECTION:
   - Three large option cards:
   
   CARD 1 (selected by default):
   - Icon: 🚗 (large)
   - Title: "自驾（默认）" (bold)
   - Description: "适合公路旅行、城市间移动"
   - Visual: Blue border, filled background
   
   CARD 2:
   - Icon: 🚴 (large)
   - Title: "骑行"
   - Description: "适合骑行游览、环湖骑行"
   - Visual: Gray border, white background
   
   CARD 3:
   - Icon: 🚶 (large)
   - Title: "步行"
   - Description: "适合城市漫步、景区游玩"
   - Visual: Gray border, white background

3. START BUTTON:
   - Full width
   - Blue background (#2196F3)
   - White text "开始记录"
   - Large, prominent

STYLE:
- Modal/bottom sheet style
- Easy to tap
- Clear visual distinction between selected/unselected
- Friendly icons
```

---

## 通用组件设计

### 1. 打卡点卡片组件

```
┌─────────────────────────────────────┐
│  📍 布达拉宫广场                     │
│  📅 2026-03-17 10:30                │
│  📍 拉萨市城关区北京东路35号          │
│  [照片缩略图] (如果有)               │
│  [查看照片]  [编辑]  [删除]          │
└─────────────────────────────────────┘
```

### 2. 停留点卡片组件

```
┌─────────────────────────────────────┐
│  📍 停留点                           │
│  📍 拉萨市城关区                     │
│  ⏱️ 停留 35分钟 (10:00 - 10:35)     │
│  [查看详情]                          │
└─────────────────────────────────────┘
```

### 3. 自动打卡提示组件

```
┌─────────────────────────────────────┐
│  ✅ 已自动打卡                        │
│  📍 拉萨市城关区北京东路              │
│  [查看]              [知道了]         │
└─────────────────────────────────────┘
```
- 小型卡片
- 3秒后自动消失
- 轻量级，不打扰

---

## 9. 登录页

**页面描述：**
简洁的登录页面，突出华为账号一键登录，无需注册。

**布局结构：**
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│           🗺️ 轨迹记录               │
│                                     │
│      记录每一次旅行的足迹             │
│                                     │
│                                     │
│                                     │
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │    [华为Logo]  华为账号登录     ││
│  │                                 ││
│  └─────────────────────────────────┘│
│         (红色大按钮)                │
│                                     │
│                                     │
│  ─────────── 其他方式 ───────────   │
│                                     │
│  ┌─────────────────────────────────┐│
│  │    [手机图标]  手机号登录        ││
│  └─────────────────────────────────┘│
│         (白色按钮)                  │
│                                     │
│  登录即表示同意                      │
│  《用户协议》和《隐私政策》           │
│                                     │
│  游客模式（部分功能受限）            │
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a clean login screen for a travel app with:

1. BRANDING AREA (top 30%):
   - App logo: 🗺️ with app name "轨迹记录"
   - Tagline: "记录每一次旅行的足迹"
   - Centered, elegant typography

2. PRIMARY LOGIN BUTTON:
   - Huawei logo icon + "华为账号登录"
   - Red background (#CF0A2C - Huawei red)
   - Full width
   - Large, prominent
   - White text

3. SECONDARY LOGIN:
   - Divider: "─────────── 其他方式 ────────────"
   - Phone icon + "手机号登录"
   - White background with gray border
   - Less prominent than Huawei button

4. TERMS & CONDITIONS:
   - Small text at bottom
   - "登录即表示同意《用户协议》和《隐私政策》"
   - Links highlighted

5. GUEST MODE (optional):
   - Small link: "游客模式（部分功能受限）"
   - Below terms text

COLORS:
- Primary button: #CF0A2C (Huawei red)
- Secondary button: white with #E0E0E0 border
- Text: #212121
- Background: #FFFFFF or light gradient

STYLE:
- Minimal, clean
- Focus on single primary action
- Professional and trustworthy
```

---

## 10. 同步状态页

**页面描述：**
显示数据同步进度和状态，让用户了解本地数据上传情况。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 数据同步                          │
├─────────────────────────────────────┤
│                                     │
│  📊 同步状态                         │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 上次同步: 2026-03-27 18:30      ││
│  │ 待同步数据:                     ││
│  │   • 打卡点: 15 个               ││
│  │   • 轨迹点: 328 个              ││
│  │   • 照片: 23 张                 ││
│  └─────────────────────────────────┘│
│                                     │
│  同步进度                            │
│  ┌─────────────────────────────────┐│
│  │ ████████████████░░░░░░ 68%     ││
│  └─────────────────────────────────┘│
│                                     │
│  正在上传第3天数据... 3/10           │
│                                     │
│  [暂停同步]         [取消]          │
│                                     │
├─────────────────────────────────────┤
│  同步历史                            │
│  ┌─────────────────────────────────┐│
│  │ 2026-03-27 18:30               ││
│  │ 成功同步 3 个行程               ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ 2026-03-26 22:15               ││
│  │ 成功同步 1 个行程               ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a data sync status screen with:

1. HEADER:
   - Back button "←"
   - Title "数据同步" centered

2. SYNC STATUS CARD:
   - Last sync time
   - Pending data summary:
     - Check-in points: 15
     - Track points: 328
     - Photos: 23

3. PROGRESS SECTION:
   - Progress bar (68% complete)
   - Current action: "正在上传第3天数据... 3/10"
   - Pause/Cancel buttons

4. SYNC HISTORY:
   - List of previous syncs
   - Each item shows:
     - Date/time
     - Result: "成功同步 X 个行程"
   - Sorted by time (newest first)

COLORS:
- Progress bar: #4CAF50 (green)
- Success status: green checkmark
- Warning: #FF9800 (orange)
- Error: #F44336 (red)

STYLE:
- Clear progress indication
- Calming colors during sync
- Easy to pause/cancel
```

---

## 11. 设置页

**页面描述：**
应用设置页面，包含账号管理、数据管理、隐私设置等。

**布局结构：**
```
┌─────────────────────────────────────┐
│  ← 设置                              │
├─────────────────────────────────────┤
│                                     │
│  👤 账号管理                         │
│  ┌─────────────────────────────────┐│
│  │ [头像] 亚哥                      ││
│  │ 华为账号已登录                   ││
│  │                     [退出登录] → ││
│  └─────────────────────────────────┘│
│                                     │
│  💾 数据管理                         │
│  ┌─────────────────────────────────┐│
│  │ 自动同步          ━━━━━━━━ ●    ││
│  │ 仅Wi-Fi同步       ○            ││
│  │ 离线地图管理      1.2GB       → ││
│  │ 清理缓存          256MB       → ││
│  └─────────────────────────────────┘│
│                                     │
│  🔒 隐私与安全                       │
│  ┌─────────────────────────────────┐│
│  │ 位置权限          已授权       → ││
│  │ 相册权限          已授权       → ││
│  │ 数据加密          已开启       → ││
│  └─────────────────────────────────┘│
│                                     │
│  📝 关于                             │
│  ┌─────────────────────────────────┐│
│  │ 版本号            v1.0.0        ││
│  │ 用户协议          →            ││
│  │ 隐私政策          →            ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

**UI提示词：**
```
Design a settings screen with grouped sections:

1. ACCOUNT SECTION:
   - User avatar (circular)
   - User name: "亚哥"
   - Status: "华为账号已登录"
   - Logout button on right

2. DATA MANAGEMENT SECTION:
   - Auto sync toggle (on by default)
   - Wi-Fi only sync toggle
   - Offline maps management (shows size: 1.2GB)
   - Clear cache button (shows size: 256MB)
   - Right arrows for navigation

3. PRIVACY & SECURITY SECTION:
   - Location permission status
   - Photo library permission status
   - Data encryption status (always on)
   - All with status indicators

4. ABOUT SECTION:
   - App version: v1.0.0
   - User agreement link
   - Privacy policy link

STYLE:
- iOS-style grouped table
- Section headers in uppercase
- Toggle switches for boolean options
- Right arrows for navigation
- Clear visual hierarchy
```

---

## 响应式设计

### 手机尺寸适配
- 小屏手机 (< 375px)：紧凑布局
- 标准手机 (375-414px)：标准布局
- 大屏手机 (> 414px)：宽松布局

### 横屏模式
- 地图区域扩大
- 数据面板侧边显示
- 按钮重新排列

---

*创建时间: 2026-03-27*
*最后更新: 2026-03-27 22:30*
*最后更新: 2026-03-27 22:21*
