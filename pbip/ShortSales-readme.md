# Short Sales Dashboard - Power BI Project

## Project Overview

This Power BI dashboard provides comprehensive analysis of short sales activities using real-time and historical ledger data. The project is built using the **PBIP (Power BI Project)** format, enabling version control and collaborative development through file-based definitions.

### Purpose
- Monitor intraday short sales positions and activities
- Track historical short sales ledger data (October 29-30, 2025)
- Provide comprehensive analytics and KPIs for short sales operations
- Enable exception tracking and reconciliation
- Support data-driven decision making for trading and risk management

---

## Data Model Architecture

### Model Configuration
- **Culture**: en-US
- **Source Query Culture**: en-NZ
- **Power BI Version**: V3
- **Time Intelligence**: Enabled
- **Mode**: Import Mode

### Table Overview

The semantic model consists of three primary fact tables with identical schemas and ten auto-generated date tables for time intelligence.

---

## Fact Tables

### 1. `Intraday_Ledger` (Unified View)

**Purpose**: Consolidated view of short sales ledger combining historical snapshots for analysis.

**Data Source**: Power Query M - Combines `ledger_2025-10-29` and `ledger_2025-10-30` tables

**M Query**:
```m
let
    Source = Table.Combine({#"ledger_2025-10-30", #"ledger_2025-10-29"}),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"BUSINESS_DATE", type text}}),
    #"Changed Type with Locale" = Table.TransformColumnTypes(#"Changed Type", {{"BUSINESS_DATE", type date}}, "en-US"),
    #"Changed Type1" = Table.TransformColumnTypes(#"Changed Type with Locale",{{"TIMESTAMP", type datetime}, {"QUANTITY", Int64.Type}, {"CURR_POSITION", Int64.Type}, {"SOD", Int64.Type}, {"IS_EXCEPTION", Int64.Type}, {"SOURCESYSTEM", type text}, {"AGGREGATION_UNIT", type text}, {"SYMBOL", type text}, {"TYPE", type text}})
in
    #"Changed Type1"
```

#### Schema

| Column | Data Type | Format | Summarization | Description |
|--------|-----------|--------|---------------|-------------|
| `SOURCESYSTEM` | String | - | None | Source system identifier |
| `TYPE` | String | - | None | Transaction type classification |
| `TIMESTAMP` | DateTime | General Date | None | Transaction timestamp |
| `AGGREGATION_UNIT` | String | - | None | Business unit or aggregation level |
| `SYMBOL` | String | - | None | Security symbol/ticker |
| `SIDE` | String | - | None | Trade side (Long/Short) |
| `QUANTITY` | Integer (Int64) | 0 | Sum | Trade quantity |
| `BOOK` | Integer (Int64) | 0 | Sum | Book identifier |
| `SOD` | Integer (Int64) | 0 | Sum | Start of Day position |
| `CURR_POSITION` | Integer (Int64) | 0 | Sum | Current position |
| `UNIQUEID` | String | - | None | Unique record identifier |
| `BUSINESS_DATE` | Date | Long Date | None | Business date for the transaction |
| `PREV_TIMESTAMP` | DateTime | General Date | None | Previous timestamp in sequence |
| `NEXT_TIMESTAMP` | DateTime | General Date | None | Next timestamp in sequence |
| `IS_EXCEPTION` | Integer (Int64) | 0 | Sum | Exception flag (1=Exception, 0=Normal) |

#### Measures

##### 1. **Total Exceptions**
```dax
Total Exceptions = SUM ( Intraday_Ledger[IS_EXCEPTION] )
```
- **Format**: Integer (0)
- **Purpose**: Counts total number of exceptions in the ledger
- **Usage**: Exception monitoring, data quality KPIs

##### 2. **Records in Ledger**
```dax
Records in Ledger = COUNTROWS ( Intraday_Ledger )
```
- **Format**: Integer (0)
- **Purpose**: Total count of all ledger records
- **Usage**: Volume analysis, data completeness checks

##### 3. **Exception %**
```dax
Exception % = DIVIDE([Total Exceptions], [Records in Ledger])
```
- **Format**: General Number (Auto-formatting)
- **Purpose**: Percentage of records flagged as exceptions
- **Usage**: Data quality metrics, exception rate monitoring

---

### 2. `ledger_2025-10-29` (Historical Snapshot)

**Purpose**: Point-in-time snapshot of short sales ledger for October 29, 2025.

**Data Source**: CSV File
- **Path**: `C:\Users\mamta\OneDrive - RegEdge LLC\Documents\Data FIles\ledger_2025-10-29.csv`
- **Delimiter**: Comma
- **Columns**: 15
- **Encoding**: Windows-1252

**M Query**:
```m
let
    Source = Csv.Document(File.Contents("C:\Users\mamta\OneDrive - RegEdge LLC\Documents\Data FIles\ledger_2025-10-29.csv"),[Delimiter=",", Columns=15, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"SOURCESYSTEM", type text}, {"TYPE", type text}, {"TIMESTAMP", type datetime}, {"AGGREGATION_UNIT", type text}, {"SYMBOL", type text}, {"SIDE", type text}, {"QUANTITY", Int64.Type}, {"BOOK", Int64.Type}, {"SOD", Int64.Type}, {"CURR_POSITION", Int64.Type}, {"UNIQUEID", type text}, {"BUSINESS_DATE", type text}, {"PREV_TIMESTAMP", type datetime}, {"NEXT_TIMESTAMP", type datetime}, {"IS_EXCEPTION", Int64.Type}})
in
    #"Changed Type"
```

#### Schema

| Column | Data Type | Format | Summarization | Description |
|--------|-----------|--------|---------------|-------------|
| `SOURCESYSTEM` | String | - | None | Source system identifier |
| `TYPE` | String | - | None | Transaction type classification |
| `TIMESTAMP` | DateTime | General Date | None | Transaction timestamp |
| `AGGREGATION_UNIT` | String | - | None | Business unit or aggregation level |
| `SYMBOL` | String | - | None | Security symbol/ticker |
| `SIDE` | String | - | None | Trade side (Long/Short) |
| `QUANTITY` | Integer (Int64) | 0 | Sum | Trade quantity |
| `BOOK` | Integer (Int64) | 0 | Sum | Book identifier |
| `SOD` | Integer (Int64) | 0 | Sum | Start of Day position |
| `CURR_POSITION` | Integer (Int64) | 0 | Sum | Current position |
| `UNIQUEID` | String | - | None | Unique record identifier |
| `BUSINESS_DATE` | String | - | None | Business date (text format) |
| `PREV_TIMESTAMP` | DateTime | General Date | None | Previous timestamp in sequence |
| `NEXT_TIMESTAMP` | DateTime | General Date | None | Next timestamp in sequence |
| `IS_EXCEPTION` | Integer (Int64) | 0 | Sum | Exception flag (1=Exception, 0=Normal) |

**Note**: `BUSINESS_DATE` is stored as String in this table, unlike `Intraday_Ledger` where it's converted to Date type.

---

### 3. `ledger_2025-10-30` (Historical Snapshot)

**Purpose**: Point-in-time snapshot of short sales ledger for October 30, 2025.

**Data Source**: CSV File
- **Path**: `C:\Users\mamta\OneDrive - RegEdge LLC\Documents\Data FIles\ledger_2025-10-30.csv`
- **Delimiter**: Comma
- **Columns**: 15
- **Encoding**: Windows-1252

**M Query**:
```m
let
    Source = Csv.Document(File.Contents("C:\Users\mamta\OneDrive - RegEdge LLC\Documents\Data FIles\ledger_2025-10-30.csv"),[Delimiter=",", Columns=15, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"SOURCESYSTEM", type text}, {"TYPE", type text}, {"TIMESTAMP", type datetime}, {"AGGREGATION_UNIT", type text}, {"SYMBOL", type text}, {"SIDE", type text}, {"QUANTITY", Int64.Type}, {"BOOK", Int64.Type}, {"SOD", Int64.Type}, {"CURR_POSITION", Int64.Type}, {"UNIQUEID", type text}, {"BUSINESS_DATE", type text}, {"PREV_TIMESTAMP", type datetime}, {"NEXT_TIMESTAMP", type datetime}, {"IS_EXCEPTION", Int64.Type}})
in
    #"Changed Type"
```

#### Schema

Identical to `ledger_2025-10-29` (see above).

---

## Dimension Tables

### Date Tables (Auto-Generated)

Power BI's Auto Date/Time feature is **enabled**, creating hidden date tables for each date/datetime column.

#### Date Hierarchy Structure

All date tables include a standard 4-level hierarchy:
1. **Year** - YYYY format
2. **Quarter** - "Qtr 1", "Qtr 2", etc.
3. **Month** - Full month name (January, February, etc.)
4. **Day** - Day of month (1-31)

#### Calculated Columns in Date Tables

| Column | DAX Formula | Purpose |
|--------|-------------|---------|
| `Year` | `YEAR([Date])` | Extract year from date |
| `MonthNo` | `MONTH([Date])` | Extract month number (1-12) |
| `Month` | `FORMAT([Date], "MMMM")` | Full month name |
| `QuarterNo` | `INT(([MonthNo] + 2) / 3)` | Calculate quarter number (1-4) |
| `Quarter` | `"Qtr " & [QuarterNo]` | Quarter label |
| `Day` | `DAY([Date])` | Extract day of month |

#### Date Tables List

| Date Table | Linked Column | Parent Table |
|------------|---------------|--------------|
| `LocalDateTable_40f5d8c0...` | `TIMESTAMP` | `ledger_2025-10-30` |
| `LocalDateTable_817b0caa...` | `PREV_TIMESTAMP` | `ledger_2025-10-30` |
| `LocalDateTable_ef8121e7...` | `NEXT_TIMESTAMP` | `ledger_2025-10-30` |
| `LocalDateTable_73df8ae1...` | `TIMESTAMP` | `ledger_2025-10-29` |
| `LocalDateTable_83bd8299...` | `PREV_TIMESTAMP` | `ledger_2025-10-29` |
| `LocalDateTable_c06aba4b...` | `NEXT_TIMESTAMP` | `ledger_2025-10-29` |
| `LocalDateTable_a257fc08...` | `TIMESTAMP` | `Intraday_Ledger` |
| `LocalDateTable_7fdc1512...` | `PREV_TIMESTAMP` | `Intraday_Ledger` |
| `LocalDateTable_683ca6eb...` | `NEXT_TIMESTAMP` | `Intraday_Ledger` |
| `LocalDateTable_b84c27a5...` | `BUSINESS_DATE` | `Intraday_Ledger` |

**Total**: 10 auto-generated date tables + 1 date template

---

## Relationships

### Relationship Configuration

**Type**: All relationships use `joinOnDateBehavior: datePartOnly`
- Joins compare only the date portion, ignoring time components
- Ensures consistent time-based filtering across the model

### Relationship Diagram

#### `ledger_2025-10-30` Relationships
```
ledger_2025-10-30.TIMESTAMP          → LocalDateTable_40f5d8c0.Date
ledger_2025-10-30.PREV_TIMESTAMP     → LocalDateTable_817b0caa.Date
ledger_2025-10-30.NEXT_TIMESTAMP     → LocalDateTable_ef8121e7.Date
```

#### `ledger_2025-10-29` Relationships
```
ledger_2025-10-29.TIMESTAMP          → LocalDateTable_73df8ae1.Date
ledger_2025-10-29.PREV_TIMESTAMP     → LocalDateTable_83bd8299.Date
ledger_2025-10-29.NEXT_TIMESTAMP     → LocalDateTable_c06aba4b.Date
```

#### `Intraday_Ledger` Relationships
```
Intraday_Ledger.TIMESTAMP            → LocalDateTable_a257fc08.Date
Intraday_Ledger.PREV_TIMESTAMP       → LocalDateTable_7fdc1512.Date
Intraday_Ledger.NEXT_TIMESTAMP       → LocalDateTable_683ca6eb.Date
Intraday_Ledger.BUSINESS_DATE        → LocalDateTable_b84c27a5.Date
```

### Relationship Properties

- **Cardinality**: Many-to-One (Fact → Dimension)
- **Cross-filter Direction**: Single (from Fact to Date)
- **Relationship Type**: Active
- **Join Behavior**: Date part only (ignores time component)

---

## Report Structure

### Report Configuration
- **Report Definition**: `Short Sales Dashboard.Report/definition.pbir`
- **Pages**: 3 report pages with 25 total visualizations
- **Theme**: Custom theme (`CY25SU11.json`)
- **Canvas Size**: 1280 x 720 (16:9 ratio)
- **Display Mode**: Fit to Page
- **Active Page**: Home (Page 1)

### Report Settings
- **Export Data Mode**: Allow Summarized
- **Default Drill Filter**: Enabled (affects other visuals)
- **Enhanced Tooltips**: Enabled
- **Stylable Visual Container Headers**: Enabled
- **Change Filter Types**: Allowed

---

## Page 1: Home (Navigation Page)

**Page Name**: `Home`  
**Page ID**: `5744c6c4db20104b30a9`  
**Visuals**: 4 visualizations  
**Purpose**: Landing page with navigation to other dashboard sections  

### Visual Breakdown

#### 1. Page Title (Textbox)
- **Type**: `textbox`
- **Position**: Top center (full width)
- **Content**: "Select a module below to navigate to the dashboard section."
- **Style**: 
  - Font: Arial, Italic, 14pt
  - Alignment: Center
  - Background: Theme color with -10% shade

#### 2. Navigation Button - Intraday Ledger
- **Type**: `actionButton`
- **Position**: Center of page
- **Text**: "Intraday Ledger"
- **Style**:
  - Font: Bold, 20pt
  - Fill Color: #2F4F9F (Dark Blue)
  - Shadow: Enabled
  - Glow: Enabled
- **Action**: Page Navigation → "Exceptions & Ledger" page
- **Functionality**: Click to navigate to Page 3

#### 3-4. Additional Visual Elements
- Static images or text for branding/layout
- Decorative elements for user interface

---

## Page 2: Exceptions Dashboard

**Page Name**: `Exceptions Dashboard`  
**Page ID**: `f01135f7e212178d8069`  
**Visuals**: 11 visualizations  
**Purpose**: Comprehensive exception analysis with interactive filtering and detailed metrics  

### Visual Breakdown

#### 1. Business Date Slicer (Dropdown)
- **Type**: `slicer`
- **Field**: `Intraday_Ledger[BUSINESS_DATE]`
- **Style**: Dropdown mode
- **Sort**: Ascending (oldest to newest)
- **Position**: Top left
- **Size**: 218 x 108 px
- **Cross-filtering**: Enabled (affects all visuals)

#### 2. Total Exceptions KPI Card
- **Type**: `card`
- **Measure**: `Total Exceptions`
- **Formula**: `SUM(Intraday_Ledger[IS_EXCEPTION])`
- **Style**:
  - Font: Bold, 30pt
  - Category Label: Visible
- **Position**: Top center-right
- **Size**: 237 x 105 px
- **Purpose**: Display total count of exception records

#### 3. Exceptions by Aggregation Unit (Column Chart)
- **Type**: `clusteredColumnChart`
- **X-Axis**: `Intraday_Ledger[AGGREGATION_UNIT]`
- **Y-Axis**: `Total Exceptions` measure
- **Sort**: Descending by Total Exceptions
- **Color**: Theme color (ColorId 2, -50% shade)
- **Position**: Top left (below slicer)
- **Size**: 557 x 200 px
- **Purpose**: Show exception distribution across business units

#### 4. Exceptions by Symbol (Treemap)
- **Type**: `treemap`
- **Group**: `Intraday_Ledger[SYMBOL]`
- **Values**: `Total Exceptions` measure
- **Legend**: Hidden
- **Position**: Left side, middle section
- **Size**: 865 x 157 px
- **Purpose**: Visual representation of exceptions by security symbol

#### 5. AGGREGATION_UNIT Slicer (List)
- **Type**: `slicer`
- **Field**: `Intraday_Ledger[AGGREGATION_UNIT]`
- **Style**: Basic list with checkboxes
- **Font Size**: 10pt
- **Cross-filtering**: Enabled

#### 6. BOOK Slicer (List)
- **Type**: `slicer`
- **Field**: `Intraday_Ledger[BOOK]`
- **Style**: Basic list with checkboxes
- **Font Size**: 10pt
- **Cross-filtering**: Enabled

#### 7. SOURCESYSTEM Slicer (List)
- **Type**: `slicer`
- **Field**: `Intraday_Ledger[SOURCESYSTEM]`
- **Style**: Basic list with checkboxes
- **Font Size**: 10pt
- **Position**: Bottom right
- **Size**: 187 x 114 px
- **Cross-filtering**: Enabled

#### 8. SYMBOL Slicer (List)
- **Type**: `slicer`
- **Field**: `Intraday_Ledger[SYMBOL]`
- **Style**: Basic list with checkboxes
- **Font Size**: 10pt
- **Position**: Bottom right
- **Size**: 168 x 108 px
- **Cross-filtering**: Enabled

#### 9. Exceptions Detail Table
- **Type**: `tableEx` (Enhanced Table)
- **Position**: Bottom section (full width)
- **Size**: 1280 x 261 px
- **Title**: "Exceptions" (Bold, white text, themed background)
- **Columns** (12 total):
  1. `SOURCESYSTEM` (text)
  2. `TYPE` (text)
  3. `TIMESTAMP` (datetime)
  4. `AGGREGATION_UNIT` (text)
  5. `SYMBOL` (text)
  6. `SIDE` (text)
  7. `QUANTITY` (sum aggregation)
  8. `BOOK` (sum aggregation)
  9. `SOD` (sum aggregation)
  10. `CURR_POSITION` (sum aggregation)
  11. `BUSINESS_DATE` (date)
  12. `UNIQUEID` (text)

**Table Filters** (19 active filters):
- `AGGREGATION_UNIT` (Categorical)
- `BOOK` (Advanced)
- `BUSINESS_DATE` - Day, Month, Quarter, Year (Date Hierarchy)
- `CURR_POSITION` (Advanced)
- `QUANTITY` (Advanced)
- `SIDE` (Categorical)
- `SOD` (Advanced)
- `SOURCESYSTEM` (Categorical)
- `SYMBOL` (Categorical)
- `TIMESTAMP` - Day, Month, Quarter, Year (Date Hierarchy)
- `TYPE` (Categorical)
- `UNIQUEID` (Categorical)
- **`IS_EXCEPTION = 1`** (Categorical - **HARD FILTER**)
  - **Filter Logic**: Only shows records where `IS_EXCEPTION = 1`
  - **Purpose**: Table displays ONLY exception records

#### 10-11. Additional Slicers
- Additional filtering controls for comprehensive data slicing

### Page 2 Key Features
- **Interactive Filtering**: 5+ slicers for multi-dimensional analysis
- **Exception Focus**: Table hard-filtered to show only exceptions
- **Cross-Visual Filtering**: All slicers affect all visuals on the page
- **Hierarchical Date Filtering**: Year → Quarter → Month → Day drill-down

---

## Page 3: Exceptions & Ledger

**Page Name**: `Exceptions & Ledger`  
**Page ID**: `2ea6893eb7d380bbde23`  
**Visuals**: 10 visualizations  
**Purpose**: Complete ledger view with exception highlighting and detailed analysis  

### Visual Breakdown

#### 1. Page Header (Textbox)
- **Type**: `textbox`
- **Position**: Top (full width except date filter)
- **Size**: 1062 x 48 px
- **Content**: "Exceptions & Ledger"
- **Style**:
  - Font: Arial Black, Bold, Italic, 20pt, Black text
  - Alignment: Center
  - Background: Theme color with -30% shade

#### 2. Business Date Slicer (Dropdown)
- **Type**: `slicer`
- **Field**: `Intraday_Ledger[BUSINESS_DATE]`
- **Style**: Dropdown mode
- **Position**: Top right corner
- **Size**: 217 x 75 px
- **Font Size**: 10pt
- **Sort**: Ascending
- **Cross-filtering**: Enabled

#### 3. SOURCESYSTEM Slicer (List)
- **Type**: `slicer`
- **Field**: `Intraday_Ledger[SOURCESYSTEM]`
- **Style**: Basic list with checkboxes
- **Position**: Below header, left side
- **Size**: 164 x 121 px
- **Font Size**: 10pt
- **Cross-filtering**: Enabled

#### 4-10. Additional Visuals
- Ledger data tables
- Exception metrics
- Position analysis charts
- Trend visualizations
- Comparative views

### Page 3 Key Features
- **Combined View**: Shows both exceptions and normal ledger records
- **Date-Driven**: Primary filtering by business date
- **Source System Analysis**: Filter by originating system
- **Comprehensive Data**: Full ledger details with exception indicators

---

## Visual Types Summary

### Chart Types Used

| Visual Type | Count | Usage | Pages |
|-------------|-------|-------|-------|
| **Slicer** (Dropdown) | 2 | Date filtering | Pages 2, 3 |
| **Slicer** (Basic List) | 6+ | Multi-select filtering | Pages 2, 3 |
| **Card** | 1+ | KPI display | Page 2 |
| **Clustered Column Chart** | 1+ | Exception distribution | Page 2 |
| **Treemap** | 1 | Symbol-based exceptions | Page 2 |
| **Table (Enhanced)** | 1+ | Detailed data view | Pages 2, 3 |
| **Textbox** | 3 | Headers and instructions | All pages |
| **Action Button** | 1 | Page navigation | Page 1 |

**Total Visuals**: 25 across 3 pages

---

## Measures Used in Visuals

### 1. Total Exceptions
- **DAX**: `SUM(Intraday_Ledger[IS_EXCEPTION])`
- **Used In**:
  - KPI Card (Page 2)
  - Column Chart Y-Axis (Page 2)
  - Treemap Values (Page 2)
- **Format**: Integer (0)
- **Purpose**: Count and display exception records

### 2. Records in Ledger
- **DAX**: `COUNTROWS(Intraday_Ledger)`
- **Used In**: Calculated fields (not directly displayed)
- **Format**: Integer (0)
- **Purpose**: Total record count for percentage calculations

### 3. Exception %
- **DAX**: `DIVIDE([Total Exceptions], [Records in Ledger])`
- **Used In**: Potential KPI cards or conditional formatting
- **Format**: Percentage
- **Purpose**: Data quality metric

---

## Filter Configurations

### Global Filters (Applied at Report Level)
- None configured (all filtering is page-level or visual-level)

### Page-Level Filters

#### Page 2: Exceptions Dashboard
- **Primary Filter**: Business Date (via slicer)
- **Secondary Filters**: 
  - AGGREGATION_UNIT
  - BOOK
  - SOURCESYSTEM
  - SYMBOL
- **Filter Behavior**: All slicers cross-filter all visuals

#### Page 3: Exceptions & Ledger
- **Primary Filter**: Business Date (via slicer)
- **Secondary Filter**: SOURCESYSTEM
- **Filter Behavior**: Slicers affect all visuals on page

### Visual-Level Filters

#### Exceptions Table (Page 2)
**Hard Filter Applied**: `IS_EXCEPTION = 1`
- **Filter Type**: Categorical
- **Logic**: 
  ```json
  WHERE IS_EXCEPTION IN (1)
  ```
- **Effect**: Table shows ONLY exception records, excluding all normal transactions
- **Total Filters**: 19 filter configurations including:
  - Categorical filters: AGGREGATION_UNIT, SIDE, SOURCESYSTEM, SYMBOL, TYPE, UNIQUEID
  - Advanced filters: BOOK, CURR_POSITION, QUANTITY, SOD
  - Date hierarchy filters: BUSINESS_DATE (Day, Month, Quarter, Year)
  - Timestamp hierarchy filters: TIMESTAMP (Day, Month, Quarter, Year)

---

## Slicer Configurations

### Dropdown Slicers
- **Field**: `BUSINESS_DATE`
- **Mode**: Single-select dropdown
- **Sort Order**: Ascending (chronological)
- **Show "Select All"**: Enabled by default
- **Pages**: 2, 3

### List Slicers (Multi-Select)
- **Fields**: 
  - `AGGREGATION_UNIT`
  - `BOOK`
  - `SOURCESYSTEM`
  - `SYMBOL`
- **Mode**: Basic list with checkboxes
- **Font Size**: 10pt
- **Select All Option**: Available
- **Search Box**: Not visible (can be enabled)
- **Cross-Filtering**: Enabled for all

### Slicer Behavior
- **Cross-Visual Interaction**: All slicers affect all visuals on the same page
- **Drill-through**: Not configured
- **Reset**: User must manually clear selections
- **Default State**: All values selected (no filter applied)

---

## Technical Details

### PBIP Format

This project uses the **Power BI Project (PBIP)** format, introduced to enable Git-based version control and team collaboration.

**Structure**:
```
pbip/
├── Short Sales Dashboard.Report/          # Report definitions
│   ├── definition/
│   │   ├── report.json                   # Report metadata
│   │   ├── version.json                  # Version tracking
│   │   └── pages/                        # Pages and visualizations
│   │       ├── pages.json               # Page registry
│   │       └── [page-id]/               # Individual page folders
│   │           ├── page.json           # Page configuration
│   │           └── visuals/            # Visual definitions
│   └── StaticResources/
│       └── SharedResources/
│           └── BaseThemes/
│               └── CY25SU11.json       # Custom theme
│
└── Short Sales Dashboard.SemanticModel/   # Data model
    ├── definition/
    │   ├── database.tmdl               # Database configuration
    │   ├── model.tmdl                  # Model settings
    │   ├── relationships.tmdl          # All relationships
    │   └── tables/                     # Table definitions
    │       ├── [TableName].tmdl       # One file per table
    │       └── ...
    └── diagramLayout.json              # Model diagram
```

**Advantages**:
- ✅ **Version Control**: All components as text files (JSON/TMDL)
- ✅ **Git Integration**: Full branching, merging, and PR workflows
- ✅ **Collaboration**: Multiple developers work independently
- ✅ **Code Review**: Changes are reviewable line-by-line
- ✅ **CI/CD Ready**: Integrates with deployment pipelines

### File Formats

#### TMDL (Tabular Model Definition Language)
- Human-readable text format for data models
- Defines tables, columns, measures, calculated columns, and relationships
- Syntax similar to DAX but optimized for model definition
- One file per table in `definition/tables/`

#### JSON Definitions
- Report structure and metadata
- Page layouts and configurations
- Visual properties and settings
- Theme customization

### Theme: CY25SU11
- **Location**: `StaticResources/SharedResources/BaseThemes/CY25SU11.json`
- **Purpose**: Consistent branding and styling across all report pages
- **Elements**: Color palette, fonts, visual defaults

---

## Visual Inventory & Specifications

### Complete Visual Catalog

#### Page 1: Home (4 Visuals)

| # | Visual Type | Field/Measure | Configuration | Purpose |
|---|-------------|---------------|---------------|---------|
| 1 | Textbox | N/A | "Select a module..." | Navigation instructions |
| 2 | Action Button | N/A | "Intraday Ledger" button | Navigate to Page 3 |
| 3-4 | UI Elements | N/A | Layout/branding | Visual design |

#### Page 2: Exceptions Dashboard (11 Visuals)

| # | Visual Type | Field/Measure | Configuration | Purpose |
|---|-------------|---------------|---------------|---------|
| 1 | Slicer (Dropdown) | `BUSINESS_DATE` | Single-select, Ascending sort | Filter by date |
| 2 | Card | `Total Exceptions` | 30pt bold, shows label | KPI - Exception count |
| 3 | Clustered Column Chart | X: `AGGREGATION_UNIT`<br>Y: `Total Exceptions` | Descending sort, themed color | Exception distribution |
| 4 | Treemap | Group: `SYMBOL`<br>Value: `Total Exceptions` | No legend | Symbol-based exceptions |
| 5 | Slicer (List) | `AGGREGATION_UNIT` | Multi-select, 10pt | Filter business units |
| 6 | Slicer (List) | `BOOK` | Multi-select, 10pt | Filter by book |
| 7 | Slicer (List) | `SOURCESYSTEM` | Multi-select, 10pt | Filter by source |
| 8 | Slicer (List) | `SYMBOL` | Multi-select, 10pt | Filter by symbol |
| 9 | Table (Enhanced) | 12 columns from Intraday_Ledger | **Hard filter: IS_EXCEPTION=1**<br>19 filter configs | Exception details |
| 10-11 | Additional Slicers | Various fields | Multi-select | Advanced filtering |

#### Page 3: Exceptions & Ledger (10 Visuals)

| # | Visual Type | Field/Measure | Configuration | Purpose |
|---|-------------|---------------|---------------|---------|
| 1 | Textbox | N/A | "Exceptions & Ledger" title | Page header |
| 2 | Slicer (Dropdown) | `BUSINESS_DATE` | Single-select, Ascending | Date filter |
| 3 | Slicer (List) | `SOURCESYSTEM` | Multi-select, 10pt | Source system filter |
| 4-10 | Mixed Visuals | Various | Tables, charts, metrics | Ledger analysis |

### Visual Properties Reference

#### Card Visuals
```json
{
  "fontSize": "30pt",
  "bold": true,
  "showCategoryLabel": true,
  "format": "Integer (0)"
}
```

#### Column Chart Configuration
```json
{
  "type": "clusteredColumnChart",
  "sort": "Descending by measure",
  "dataPointColor": "ThemeDataColor ID 2, -50% shade",
  "crossFilter": true
}
```

#### Treemap Configuration
```json
{
  "type": "treemap",
  "groupField": "SYMBOL",
  "valueField": "Total Exceptions",
  "showLegend": false,
  "crossFilter": true
}
```

#### Slicer - Dropdown Configuration
```json
{
  "mode": "Dropdown",
  "orientation": "Vertical (0D)",
  "fontSize": "10pt",
  "sortOrder": "Ascending",
  "crossFilter": true
}
```

#### Slicer - List Configuration
```json
{
  "mode": "Basic",
  "orientation": "Vertical",
  "fontSize": "10pt",
  "showSelectAll": true,
  "crossFilter": true
}
```

#### Enhanced Table Configuration
```json
{
  "type": "tableEx",
  "columns": 12,
  "totalRows": "Dynamic based on filter",
  "conditionalFormatting": "None configured",
  "columnWidth": "Auto-sized",
  "wordWrap": "Enabled"
}
```

---

## Interactive Features

### Cross-Filtering Behavior
- **Enabled On**: All slicers and most visuals
- **Direction**: Bi-directional (visual selections affect others)
- **Scope**: Page-level (does not affect other pages)
- **Reset**: Manual - user must clear selections

### Drill-Through Capabilities
- **Configured**: No drill-through pages
- **Drill-Down**: Available on date hierarchy visuals
- **Drill Mode**: Disabled by default

### Tooltips
- **Type**: Enhanced tooltips (enabled)
- **Custom Tooltip Pages**: None configured
- **Default Behavior**: Show field name and value
- **Format**: Follows theme styling

### Bookmarks
- **Created**: None visible in report definition
- **Personal Bookmarks**: User can create
- **Shared Bookmarks**: Not configured

### Navigation
- **Page Navigation**: Action button on Home page
- **Page Order**:
  1. Home (5744c6c4db20104b30a9)
  2. Exceptions Dashboard (f01135f7e212178d8069)
  3. Exceptions & Ledger (2ea6893eb7d380bbde23)
- **Active Page on Open**: Home

---

## Color Scheme & Theming

### Theme: CY25SU11
**Location**: `StaticResources/SharedResources/BaseThemes/CY25SU11.json`

### Color Usage

| Element | Color | Usage |
|---------|-------|-------|
| Primary Button | `#2F4F9F` | Action button fill |
| Data Points | Theme Color ID 2, -50% | Chart bars |
| Headers | Theme Color ID 0, -30% | Page titles |
| Background | Theme Color ID 0, -10% | Textbox backgrounds |
| Text | `#000000` (Black) | Page titles |
| Text (Alt) | `#FFFFFF` (White) | Table headers |

### Font Scheme

| Element | Font Family | Size | Weight | Style |
|---------|-------------|------|--------|-------|
| Page Titles | Arial Black | 20pt | Bold | Italic |
| Instructions | Arial | 14pt | Normal | Italic |
| Button Text | Default | 20pt | Bold | Normal |
| KPI Values | Default | 30pt | Bold | Normal |
| Slicer Items | Default | 10pt | Normal | Normal |
| Table Text | Default | Auto | Normal | Normal |

---

## DAX Measures Reference

### Exception Monitoring Measures

#### Total Exceptions
```dax
Total Exceptions = SUM ( Intraday_Ledger[IS_EXCEPTION] )
```
- **Table**: `Intraday_Ledger`
- **Output**: Integer
- **Business Logic**: Sums the `IS_EXCEPTION` flag (1 = exception, 0 = normal)
- **Use Cases**:
  - Exception count cards
  - Exception trend analysis
  - Alerting thresholds

#### Records in Ledger
```dax
Records in Ledger = COUNTROWS ( Intraday_Ledger )
```
- **Table**: `Intraday_Ledger`
- **Output**: Integer
- **Business Logic**: Counts all rows in the ledger table
- **Use Cases**:
  - Data volume monitoring
  - Completeness validation
  - Record count trend over time

#### Exception %
```dax
Exception % = DIVIDE([Total Exceptions], [Records in Ledger])
```
- **Table**: `Intraday_Ledger`
- **Output**: Decimal (auto-formatted as percentage)
- **Business Logic**: Calculates percentage of records with exceptions
- **Use Cases**:
  - Data quality KPI
  - Exception rate monitoring
  - Threshold breach detection

**Error Handling**: Uses `DIVIDE()` function which safely handles division by zero (returns BLANK instead of error)

---

## Data Dictionary

### Field Definitions

| Field Name | Business Definition | Expected Values | Notes |
|------------|---------------------|-----------------|-------|
| `SOURCESYSTEM` | Originating trading system or platform | Text | e.g., "BLOOMBERG", "TRADE_SYS" |
| `TYPE` | Transaction or position type | Text | Classification of trade type |
| `TIMESTAMP` | Transaction date and time | DateTime | Precise timestamp of event |
| `AGGREGATION_UNIT` | Business unit or desk | Text | Trading desk or business unit |
| `SYMBOL` | Security ticker symbol | Text | Standard ticker (e.g., "AAPL", "MSFT") |
| `SIDE` | Trade direction | Text | "LONG" or "SHORT" |
| `QUANTITY` | Number of shares/units | Integer | Absolute quantity |
| `BOOK` | Trading book identifier | Integer | Book number for position tracking |
| `SOD` | Start of Day position | Integer | Opening position for the day |
| `CURR_POSITION` | Current position | Integer | Real-time or latest position |
| `UNIQUEID` | Unique record identifier | String | Primary key for deduplication |
| `BUSINESS_DATE` | Trading business date | Date | Business day (excludes weekends/holidays) |
| `PREV_TIMESTAMP` | Previous event timestamp | DateTime | Used for sequencing |
| `NEXT_TIMESTAMP` | Next event timestamp | DateTime | Used for sequencing |
| `IS_EXCEPTION` | Exception indicator | 0 or 1 | 1 = Exception, 0 = Normal |

### Key Metrics

| Metric | Calculation | Description |
|--------|-------------|-------------|
| **Total Exceptions** | SUM(IS_EXCEPTION) | Count of all exception records |
| **Records in Ledger** | COUNTROWS() | Total ledger entries |
| **Exception %** | Exceptions / Total Records | Percentage of records with issues |
| **Total Quantity** | SUM(QUANTITY) | Aggregate trade volume |
| **Net Position** | SUM(CURR_POSITION) | Current net position across all symbols |
| **SOD Position** | SUM(SOD) | Aggregate start of day position |

---

## Data Refresh Strategy

### Current Configuration
- **Mode**: Import Mode (full data load)
- **Source**: CSV files on local/network drive
- **Tables**: 2 historical snapshots + 1 combined table

### Recommended Refresh Strategy

#### Historical Snapshots
- **Tables**: `ledger_2025-10-29`, `ledger_2025-10-30`
- **Frequency**: Static (historical data, no refresh needed)
- **Method**: Manual update when new historical periods are required
- **Retention**: Archive old snapshots when no longer needed for analysis

#### Intraday Data
- **Table**: `Intraday_Ledger` (combines both snapshots)
- **Current State**: Combines historical snapshots
- **Recommended**: If true intraday data is needed:
  - Connect to live data source (database, API)
  - Configure scheduled refresh (every 15-30 minutes)
  - Implement incremental refresh for large datasets

### Future Enhancements

1. **Dynamic Date-Based Tables**:
   - Replace hardcoded date tables with parameterized queries
   - Automatically load latest N days of data
   - Archive old data to separate tables

2. **Incremental Refresh**:
   - Configure for `Intraday_Ledger` table
   - Keep last 7 days in incremental refresh window
   - Archive older data for historical analysis

3. **Data Source Migration**:
   - Move from CSV files to database connection
   - Implement data gateway for cloud refresh
   - Add data transformation logic in source system

---

## Performance Optimization

### Current Model Size
- **Tables**: 3 fact tables + 11 date tables = 14 tables
- **Relationships**: 10 active relationships
- **Measures**: 3 DAX measures

### Optimization Recommendations

#### 1. Disable Auto Date/Time
**Current State**: Enabled (10 hidden date tables created)

**Impact**: 
- Increases model size significantly
- Creates redundant date hierarchies
- Slower refresh times

**Recommendation**:
```
Power BI Desktop → Options → Data Load → Time Intelligence
☐ Uncheck "Auto Date/Time"
```

**Alternative**: Create a single dedicated `Date` dimension table:
```dax
Date = 
CALENDAR(
    DATE(2025, 10, 1),  -- Start date
    DATE(2025, 12, 31)   -- End date
)
```

#### 2. Optimize Column Data Types
- ✅ Integer columns correctly set to `Int64`
- ✅ Dates use appropriate date/datetime types
- ⚠️ `BUSINESS_DATE` inconsistent (String in source, Date in Intraday_Ledger)

**Recommendation**: Standardize `BUSINESS_DATE` to Date type in all source tables.

#### 3. Remove Unused Columns
Review columns not used in any visuals or measures:
- `PREV_TIMESTAMP` - Used for sequencing?
- `NEXT_TIMESTAMP` - Used for sequencing?
- `UNIQUEID` - Used only for deduplication?

**Action**: Hide or remove columns not required for analysis.

#### 4. Aggregation Tables
For large datasets (millions of rows), create aggregation tables:
```dax
Ledger_Daily_Aggregate = 
SUMMARIZE(
    Intraday_Ledger,
    Intraday_Ledger[BUSINESS_DATE],
    Intraday_Ledger[SYMBOL],
    Intraday_Ledger[SIDE],
    "Total_Quantity", SUM(Intraday_Ledger[QUANTITY]),
    "Total_Exceptions", SUM(Intraday_Ledger[IS_EXCEPTION])
)
```

---

## Development Guidelines

### Working with PBIP

#### Opening the Project
```
1. Open Power BI Desktop
2. File → Open Report → Browse
3. Navigate to: pbip\Short Sales Dashboard.Report\
4. Select: definition.pbir
```

#### Making Changes

**Semantic Model Changes**:
1. Open Power BI Desktop with the report
2. Modify data model (tables, relationships, measures)
3. Save the project
4. TMDL files automatically update in `definition/tables/`
5. Commit changes to version control

**Report Changes**:
1. Modify visuals, pages, or formatting
2. Save the project
3. JSON files automatically update in `definition/pages/`
4. Commit changes to version control

### Version Control Best Practices

#### Commit Strategy
```bash
# Semantic model changes
git add "pbip/Short Sales Dashboard.SemanticModel/**"
git commit -m "feat: Add Exception Rate % measure"

# Report visual changes
git add "pbip/Short Sales Dashboard.Report/**"
git commit -m "style: Update dashboard theme colors"

# Combined changes
git add pbip/
git commit -m "feat: Add historical comparison page with new measures"
```

#### Branch Strategy
```
main
├── develop
│   ├── feature/add-new-measures
│   ├── feature/historical-analysis-page
│   └── hotfix/fix-exception-calculation
```

#### Pull Request Checklist
- [ ] TMDL changes reviewed for DAX logic correctness
- [ ] Measure formatting validated
- [ ] Relationships maintain proper cardinality
- [ ] Report tested with sample data
- [ ] No hardcoded file paths in production code
- [ ] Performance impact assessed

---

## Deployment Guide

### Prerequisites
- Power BI Desktop (latest version)
- Access to data source files
- Power BI Service account (for publishing)

### Local Development Setup

1. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd ShortSales-main
   ```

2. **Update Data Source Paths**:
   Edit TMDL files to update CSV file paths:
   - `tables/ledger_2025-10-29.tmdl`
   - `tables/ledger_2025-10-30.tmdl`
   
   Update the file path in the M query:
   ```m
   Source = Csv.Document(File.Contents("YOUR_PATH\ledger_2025-10-29.csv"), ...)
   ```

3. **Open Project**:
   - Open Power BI Desktop
   - File → Open → `pbip\Short Sales Dashboard.Report\definition.pbir`

4. **Refresh Data**:
   - Home tab → Refresh
   - Verify data loads successfully

### Publishing to Power BI Service

1. **Publish Report**:
   ```
   Home → Publish → Select workspace
   ```

2. **Configure Scheduled Refresh** (if using live data):
   ```
   Power BI Service → Dataset Settings → Scheduled Refresh
   - Set refresh frequency
   - Configure data source credentials
   - Enable email notifications on failure
   ```

3. **Set Up Row-Level Security** (if needed):
   ```
   Power BI Service → Dataset → Security
   - Define RLS roles
   - Assign users to roles
   ```

---

## Troubleshooting

### Common Issues

#### 1. Data Source Path Errors
**Error**: "Couldn't refresh the entity because of an issue with the mashup document"

**Cause**: Hardcoded file paths don't exist on current machine

**Solution**:
```m
# Update the file path in source tables:
File.Contents("C:\Users\[USERNAME]\...\ledger_2025-10-29.csv")
# Change to your local path
```

#### 2. Relationship Errors
**Error**: "Relationship uses columns with different data types"

**Cause**: Date column type mismatch

**Solution**: Ensure `BUSINESS_DATE` is Date type in all tables:
```m
#"Changed Type" = Table.TransformColumnTypes(#"Previous Step", {{"BUSINESS_DATE", type date}})
```

#### 3. Measure Calculation Errors
**Error**: "The expression refers to multiple columns. Multiple columns cannot be converted to a scalar value."

**Cause**: Incorrect DAX syntax in measures

**Solution**: Review measure definition, ensure proper aggregation functions used.

#### 4. Slow Report Performance
**Symptoms**: Visuals take >5 seconds to load

**Solutions**:
- Disable Auto Date/Time
- Reduce number of visuals per page
- Optimize DAX measures (avoid calculated columns where possible)
- Check for many-to-many relationships
- Review visual-level filters

---

## Maintenance Checklist

### Weekly
- [ ] Verify data refresh success
- [ ] Monitor exception rates for anomalies
- [ ] Check report performance metrics

### Monthly
- [ ] Review and archive old ledger snapshot tables
- [ ] Update date table range (if using custom date table)
- [ ] Audit unused measures and columns
- [ ] Review DAX measure performance

### Quarterly
- [ ] Optimize data model (remove unused tables/columns)
- [ ] Review and update documentation
- [ ] Assess need for aggregation tables
- [ ] Update custom theme if branding changes

---

## Security and Compliance

### Data Sensitivity
⚠️ **CONFIDENTIAL**: This dashboard contains proprietary trading data.

### Access Controls
- Restrict access to authorized personnel only
- Implement Row-Level Security (RLS) if needed
- Regular access audits

### Compliance Requirements
- Maintain audit trail of data changes
- Ensure data retention policies are followed
- Document data lineage and transformations
- Follow internal data governance policies

---

## Contact and Support

### Project Ownership
- **Organization**: Jefferies LLC
- **Department**: Trading Operations
- **Location**: `c:\Users\PChinnaiyapillai\OneDrive - Jefferies LLC\ShortSales-main\pbip`

### Technical Support
For issues or questions regarding:
- **Data Model**: Contact BI team
- **Data Source**: Contact data engineering team
- **Report Access**: Contact Power BI administrators

### Documentation Updates
Last updated: December 10, 2025

---

## Appendix

### Related Documentation
- Power BI Project (PBIP) format: [Microsoft Docs](https://learn.microsoft.com/en-us/power-bi/developer/projects/)
- TMDL Reference: [Tabular Model Definition Language](https://learn.microsoft.com/en-us/analysis-services/tmsl/)
- DAX Function Reference: [DAX Guide](https://dax.guide/)

### Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-10-29 | 1.0 | Initial ledger snapshot imported | - |
| 2025-10-30 | 1.1 | Added second day snapshot | - |
| 2025-12-10 | 2.0 | Comprehensive documentation created | AI Assistant |

---

## Quick Reference Guide

### Data Model at a Glance

| Component | Count | Details |
|-----------|-------|---------|
| **Fact Tables** | 3 | Intraday_Ledger (combined), ledger_2025-10-29, ledger_2025-10-30 |
| **Date Tables** | 11 | 1 template + 10 auto-generated local tables |
| **Total Columns** | 15 per fact table | 12 descriptive + 3 numeric aggregates |
| **Measures** | 3 | Total Exceptions, Records in Ledger, Exception % |
| **Relationships** | 10 | All Many-to-One, Date part only |
| **Data Source** | CSV Files | 2 files, 15 columns, Windows-1252 encoding |

### Report at a Glance

| Component | Count | Details |
|-----------|-------|---------|
| **Pages** | 3 | Home, Exceptions Dashboard, Exceptions & Ledger |
| **Total Visuals** | 25 | 8 slicers, 1 card, 1 chart, 1 treemap, 1+ tables, etc. |
| **Canvas Size** | 1280x720 | 16:9 aspect ratio, Fit to Page |
| **Theme** | Custom | CY25SU11.json |
| **Navigation** | Button | Home page navigates to Page 3 |

### Key Metrics Reference

| Metric | DAX Formula | Purpose | Format |
|--------|-------------|---------|--------|
| **Total Exceptions** | `SUM(Intraday_Ledger[IS_EXCEPTION])` | Exception count | Integer |
| **Records in Ledger** | `COUNTROWS(Intraday_Ledger)` | Total records | Integer |
| **Exception %** | `DIVIDE([Total Exceptions], [Records in Ledger])` | Exception rate | Percentage |

### Filterable Fields

**Available Slicers**:
- `BUSINESS_DATE` - Primary date filter (Dropdown)
- `AGGREGATION_UNIT` - Business unit filter (List)
- `BOOK` - Trading book filter (List)
- `SOURCESYSTEM` - Source system filter (List)
- `SYMBOL` - Security symbol filter (List)

**Table Filters** (19 total on Exceptions table):
- All fields from Intraday_Ledger
- Date hierarchies (Year, Quarter, Month, Day)
- **Hard Filter**: `IS_EXCEPTION = 1` (Exceptions table only)

### Visual Type Distribution

```
Slicers:      8 (32%)  - Dropdown (2), List (6+)
Tables:       2+ (8%)  - Enhanced table with filters
Charts:       1 (4%)   - Clustered column chart
Treemap:      1 (4%)   - Symbol-based visualization
Cards:        1 (4%)   - KPI display
Buttons:      1 (4%)   - Navigation action
Textboxes:    3 (12%)  - Headers and instructions
Other:        8 (32%)  - Layout and design elements
```

### Page Navigation Map

```
┌─────────────────────┐
│  Page 1: Home       │
│  (Navigation Hub)   │
└──────────┬──────────┘
           │
           │ [Intraday Ledger Button]
           ↓
┌─────────────────────┐
│  Page 3:            │
│  Exceptions &       │
│  Ledger             │
└─────────────────────┘

┌─────────────────────┐
│  Page 2:            │
│  Exceptions         │
│  Dashboard          │
│  (Manual Nav)       │
└─────────────────────┘
```

### Data Flow Diagram

```
CSV Files (2)
   │
   ├─ ledger_2025-10-29.csv
   │     │
   │     ├─ Load → ledger_2025-10-29 Table
   │     │
   └─ ledger_2025-10-30.csv
         │
         ├─ Load → ledger_2025-10-30 Table
         │
         └─ Combine Tables ──→ Intraday_Ledger
                                      │
                                      ├─ 3 DAX Measures
                                      │
                                      ├─ 4 Date Relationships
                                      │
                                      └─ Visualizations (25)
```

### Common Tasks Quick Reference

#### Opening the Report
1. Launch Power BI Desktop
2. File → Open Report
3. Navigate to: `pbip\Short Sales Dashboard.Report\`
4. Open: `definition.pbir`

#### Refreshing Data
1. Home tab → Refresh
2. Wait for completion
3. Check for errors in Applied Steps

#### Filtering Data
- **By Date**: Use BUSINESS_DATE dropdown slicer
- **By Symbol**: Use SYMBOL list slicer
- **By Source**: Use SOURCESYSTEM list slicer
- **Reset Filters**: Click eraser icon on each slicer

#### Analyzing Exceptions
1. Navigate to "Exceptions Dashboard" (Page 2)
2. Select date range using BUSINESS_DATE slicer
3. View Total Exceptions KPI card
4. Analyze distribution in column chart
5. Review details in bottom table (pre-filtered to exceptions only)

#### Exporting Data
1. Click "..." on any visual
2. Select "Export data"
3. Choose "Summarized data" or "Underlying data"
4. Save as CSV or Excel

### File Paths Reference

| Component | Path |
|-----------|------|
| **Report Definition** | `pbip\Short Sales Dashboard.Report\definition.pbir` |
| **Semantic Model** | `pbip\Short Sales Dashboard.SemanticModel\definition.pbism` |
| **Pages Metadata** | `pbip\Short Sales Dashboard.Report\definition\pages\pages.json` |
| **Theme File** | `pbip\Short Sales Dashboard.Report\StaticResources\SharedResources\BaseThemes\CY25SU11.json` |
| **Table Definitions** | `pbip\Short Sales Dashboard.SemanticModel\definition\tables\*.tmdl` |
| **Relationships** | `pbip\Short Sales Dashboard.SemanticModel\definition\relationships.tmdl` |
| **Model Config** | `pbip\Short Sales Dashboard.SemanticModel\definition\model.tmdl` |

### Color Palette Quick Reference

| Color | Hex Code | Usage |
|-------|----------|-------|
| Primary Blue | `#2F4F9F` | Action buttons, emphasis |
| White | `#FFFFFF` | Table headers, contrast text |
| Black | `#000000` | Page titles, body text |
| Theme Color 0, -10% | Auto | Light backgrounds |
| Theme Color 0, -30% | Auto | Headers |
| Theme Color 2, -50% | Auto | Charts, data points |

### Filter Priority & Interaction

**Filter Execution Order**:
1. Visual-level filters (e.g., `IS_EXCEPTION = 1`)
2. Page-level filters (via slicers)
3. Report-level filters (none configured)

**Cross-Filtering**:
- ✅ **Enabled**: All slicers affect all visuals on same page
- ✅ **Drill-down**: Available on date hierarchy visuals
- ❌ **Drill-through**: Not configured
- ❌ **Sync Slicers**: Not configured across pages

---

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| **Can't find data files** | Update M query file paths in table definitions |
| **Date slicer empty** | Check BUSINESS_DATE column has valid dates |
| **Table shows no data** | Check `IS_EXCEPTION = 1` filter on Exceptions table |
| **Measure returns blank** | Verify filter context includes data |
| **Visuals load slowly** | Reduce slicer selections, optimize filters |
| **Can't navigate pages** | Use page tabs at bottom or action button on Home |
| **Theme not applied** | Verify `CY25SU11.json` exists in StaticResources |
| **Refresh fails** | Check CSV file paths and permissions |

---

**End of Documentation**

---

## Document Information

- **Version**: 2.0
- **Last Updated**: December 10, 2025
- **Author**: AI Assistant
- **Purpose**: Comprehensive technical documentation for Short Sales Dashboard Power BI Project
- **Format**: Markdown (GitHub-flavored)
- **Sections**: 30+
- **Page Count**: 1300+ lines
- **Coverage**: Data Model, Measures, Relationships, Visuals, Filters, Configuration

*   **`Short Sales Dashboard.Report`**: Contains the visuals, page layout, and formatting (JSON).
*   **`Short Sales Dashboard.SemanticModel`**: Contains the data schema, measures, and Power Query (M) logic (TMDL).

### How to Edit
1.  Open `Short Sales Dashboard.pbip` in Power BI Desktop.
2.  Make changes in the GUI.
3.  Save the project. Power BI will update the text files in the `definition` folders automatically.

### Version Control Note
The `.gitignore` file is present, ensuring that temporary files (like `.platform` and cache) are not committed to Git.