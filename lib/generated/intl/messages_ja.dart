// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ja';

  static String m0(name) => "「${name}」に追加しました";

  static String m1(n) => "荷重 ${n}";

  static String m2(label) => "${label}をコピーしました";

  static String m3(label) => "線に沿ってドラッグすると${label}の他の値を確認できます。";

  static String m4(x) => "x = ${x} の固定モーメント";

  static String m5(index) => "第${index}層";

  static String m6(index) => "第${index}次モード";

  static String m7(total) => "${total} 件すべてのツール — 機械設計、複合材料、流体・伝熱、振動ほか";

  static String m8(count, total) =>
      "${total} 件のうち ${count} 件のツールを無料で使えます。プレミアムで残りも解除されます。";

  static String m9(count) => "最新の ${count} 件を表示しています。プレミアムではすべて表示されます。";

  static String m10(tool) => "「${tool}」はプレミアムのツールです";

  static String m11(value) => "プレビュー：${value}";

  static String m12(count) => "計算 ${count} 件";

  static String m13(name) => "「${name}」を保存しました";

  static String m14(name) => "「${name}」に名前を変更しました";

  static String m15(x) => "x = ${x} の反力";

  static String m16(tool) => "${tool}をお気に入りから削除";

  static String m17(n) => "寸法 ${n}";

  static String m18(label) => "もし〜なら: ${label}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "A_From_A": MessageLookupByLibrary.simpleMessage("a（Aからの距離）"),
    "About_This_Tool": MessageLookupByLibrary.simpleMessage("このツールについて"),
    "Active_Coils_Na": MessageLookupByLibrary.simpleMessage("有効巻数、Na"),
    "Add_Custom_Material": MessageLookupByLibrary.simpleMessage("カスタム材料を追加"),
    "Add_Dimension": MessageLookupByLibrary.simpleMessage("寸法を追加"),
    "Add_Force": MessageLookupByLibrary.simpleMessage("力を追加"),
    "Add_Joint": MessageLookupByLibrary.simpleMessage("節点を追加"),
    "Add_Layer": MessageLookupByLibrary.simpleMessage("層を追加"),
    "Add_Load": MessageLookupByLibrary.simpleMessage("荷重を追加"),
    "Add_Member": MessageLookupByLibrary.simpleMessage("部材を追加"),
    "Add_Shape": MessageLookupByLibrary.simpleMessage("形状を追加"),
    "Add_to_Favorites": MessageLookupByLibrary.simpleMessage("お気に入りに追加"),
    "Added_To_Project": m0,
    "Added_to_Favorites": MessageLookupByLibrary.simpleMessage("お気に入りに追加しました"),
    "Ads_Removed": MessageLookupByLibrary.simpleMessage("広告を削除しました"),
    "Ads_Removed_Description": MessageLookupByLibrary.simpleMessage(
      "ME Toolkitをご支援いただきありがとうございます。",
    ),
    "Aerospace_Engineering": MessageLookupByLibrary.simpleMessage("航空宇宙工学"),
    "All": MessageLookupByLibrary.simpleMessage("すべて"),
    "Allowable_Shear_Stress_Optional": MessageLookupByLibrary.simpleMessage(
      "許容せん断応力（任意）",
    ),
    "Alternating_Moment_Ma": MessageLookupByLibrary.simpleMessage(
      "変動曲げモーメント、Ma",
    ),
    "Alternating_Torque_Ta": MessageLookupByLibrary.simpleMessage("変動トルク、Ta"),
    "Ambient_Temperature": MessageLookupByLibrary.simpleMessage("周囲温度"),
    "Analysis_Type": MessageLookupByLibrary.simpleMessage("解析タイプ"),
    "Angle_of_Rotation": MessageLookupByLibrary.simpleMessage("回転角"),
    "Angle_of_twist": MessageLookupByLibrary.simpleMessage("ねじれ角"),
    "Anisotropic_material": MessageLookupByLibrary.simpleMessage("異方性材料"),
    "Answer_No": MessageLookupByLibrary.simpleMessage("いいえ"),
    "Answer_Yes": MessageLookupByLibrary.simpleMessage("はい"),
    "Appearance": MessageLookupByLibrary.simpleMessage("外観"),
    "Applied_Force_F": MessageLookupByLibrary.simpleMessage("作用力、F"),
    "Area": MessageLookupByLibrary.simpleMessage("断面積"),
    "Area_A": MessageLookupByLibrary.simpleMessage("断面積、A"),
    "Axial_Load_F": MessageLookupByLibrary.simpleMessage("軸方向荷重 F"),
    "Ball_Bearing": MessageLookupByLibrary.simpleMessage("玉軸受（p = 3）"),
    "Base_Temperature": MessageLookupByLibrary.simpleMessage("フィン基部温度"),
    "Beam_And_Supports": MessageLookupByLibrary.simpleMessage("はりと支持条件"),
    "Beam_Cantilever": MessageLookupByLibrary.simpleMessage("片持ち"),
    "Beam_Configuration": MessageLookupByLibrary.simpleMessage("梁の構成"),
    "Beam_Determinate_Note": MessageLookupByLibrary.simpleMessage(
      "静定です。反力はつり合いだけから求まります。",
    ),
    "Beam_Engineering": MessageLookupByLibrary.simpleMessage("梁の計算"),
    "Beam_Fixed_Fixed": MessageLookupByLibrary.simpleMessage("両端固定"),
    "Beam_Fixed_Pinned": MessageLookupByLibrary.simpleMessage("固定–ピン"),
    "Beam_Free_Free": MessageLookupByLibrary.simpleMessage("自由–自由"),
    "Beam_Frequency_Footnote": MessageLookupByLibrary.simpleMessage(
      "オイラー・ベルヌーイ理論のため、せん断変形と回転慣性を無視します。短く太いはり（L/dが約10未満）や高次モードでは振動数が高めに出ます。",
    ),
    "Beam_Indeterminate_Note": MessageLookupByLibrary.simpleMessage(
      "不静定です。反力が EI に依存するため、断面と材料はたわみだけでなく反力そのものも変えます。",
    ),
    "Beam_Length_L": MessageLookupByLibrary.simpleMessage("はりの長さ, L"),
    "Beam_Load_Analysis": MessageLookupByLibrary.simpleMessage("梁の荷重解析"),
    "Beam_Load_N": m1,
    "Beam_Loads": MessageLookupByLibrary.simpleMessage("荷重"),
    "Beam_Mode_Constant": MessageLookupByLibrary.simpleMessage("モード定数, βL"),
    "Beam_Model_Note": MessageLookupByLibrary.simpleMessage(
      "線形弾性のオイラー・ベルヌーイはりを 120 要素に分割して解いています。自重は分布荷重として入力しない限り含まれません。せん断変形も無視しているため、スパンがはりの高さの約 10 倍より短い場合はたわみを小さく見積もります。",
    ),
    "Beam_Natural_Frequency": MessageLookupByLibrary.simpleMessage("はりの固有振動数"),
    "Beam_Properties": MessageLookupByLibrary.simpleMessage("はりの諸元"),
    "Beam_Section_Properties": MessageLookupByLibrary.simpleMessage("梁の断面性能"),
    "Beam_Simply_Supported": MessageLookupByLibrary.simpleMessage("単純支持"),
    "Bearing_L10_Life": MessageLookupByLibrary.simpleMessage("軸受のL10寿命"),
    "Belt_Chain_Drive": MessageLookupByLibrary.simpleMessage("ベルト・チェーン伝動"),
    "Belt_Length_L": MessageLookupByLibrary.simpleMessage("ベルト長さ、L"),
    "Belt_Pull_Ft": MessageLookupByLibrary.simpleMessage("ベルト張力、Ft"),
    "Bending_Moment_Diagram": MessageLookupByLibrary.simpleMessage("曲げモーメント図"),
    "Bending_Stress_At_Mmax": MessageLookupByLibrary.simpleMessage(
      "Mmax における曲げ応力",
    ),
    "Bending_Stress_Pinion": MessageLookupByLibrary.simpleMessage(
      "曲げ応力、σ（ピニオン）",
    ),
    "Bolt_Grades_Footnote": MessageLookupByLibrary.simpleMessage(
      "締付軸力は有効断面積にかかる保証応力の 75 % です。トルクは T = K·F·d（K = 0.2、無処理・無潤滑のねじ）で求めています。K は摩擦のすべてを 1 つの数値に押し込んだもので、めっき・ワックス・焼付き防止剤によって 0.10〜0.25 程度まで変化し、トルクもそれに従って変わります。軸力が重要な場合はトルクレンチに頼らず実測してください。行をタップするとコピーできます。",
    ),
    "Bolt_Grades_Torque": MessageLookupByLibrary.simpleMessage("ボルト強度区分と締付トルク"),
    "Bolt_Preload_Torque_Tension": MessageLookupByLibrary.simpleMessage(
      "ボルトの初期張力 / トルク・張力",
    ),
    "Bolt_Size": MessageLookupByLibrary.simpleMessage("サイズ"),
    "Bolted_Riveted_Joint": MessageLookupByLibrary.simpleMessage("ボルト・リベット継手"),
    "Both": MessageLookupByLibrary.simpleMessage("両方"),
    "Buckling_Load": MessageLookupByLibrary.simpleMessage("座屈荷重"),
    "Buckling_load_of_column": MessageLookupByLibrary.simpleMessage("柱の座屈荷重"),
    "Calculate": MessageLookupByLibrary.simpleMessage("計算"),
    "Calculation": MessageLookupByLibrary.simpleMessage("計算"),
    "Calculation_Copied": MessageLookupByLibrary.simpleMessage("計算をコピーしました"),
    "Cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "Center_Distance": MessageLookupByLibrary.simpleMessage("軸間距離"),
    "Center_Distance_C": MessageLookupByLibrary.simpleMessage("軸間距離、C"),
    "Centroid_of_Composite_Area": MessageLookupByLibrary.simpleMessage(
      "合成断面の図心",
    ),
    "Choose_Project": MessageLookupByLibrary.simpleMessage("プロジェクトを選択"),
    "Circular_Frequency_Omega": MessageLookupByLibrary.simpleMessage(
      "角固有振動数, ω",
    ),
    "Civil_Structural_Engineering": MessageLookupByLibrary.simpleMessage(
      "土木・構造工学",
    ),
    "Clamp_Load_Fi": MessageLookupByLibrary.simpleMessage("締付軸力 Fi"),
    "Clear": MessageLookupByLibrary.simpleMessage("削除"),
    "Clear_History": MessageLookupByLibrary.simpleMessage("履歴を削除"),
    "Clear_History_Description": MessageLookupByLibrary.simpleMessage(
      "この端末に保存されているすべての計算履歴が削除されます。",
    ),
    "Clear_History_Question": MessageLookupByLibrary.simpleMessage(
      "履歴を削除しますか？",
    ),
    "Clear_Search": MessageLookupByLibrary.simpleMessage("検索をクリア"),
    "Clearance_Close": MessageLookupByLibrary.simpleMessage("すきまばめ（精級）"),
    "Clearance_Free": MessageLookupByLibrary.simpleMessage("すきまばめ（並級）"),
    "Clearance_um": MessageLookupByLibrary.simpleMessage("すきま (µm)"),
    "Closing_Gap": MessageLookupByLibrary.simpleMessage("すきま"),
    "Cold_Inlet": MessageLookupByLibrary.simpleMessage("低温側入口"),
    "Cold_Outlet": MessageLookupByLibrary.simpleMessage("低温側出口"),
    "Cold_Stream_Range": MessageLookupByLibrary.simpleMessage("低温側温度変化"),
    "Collar_Diameter_Dc": MessageLookupByLibrary.simpleMessage("つばの平均直径 dc"),
    "Collar_Friction_Muc": MessageLookupByLibrary.simpleMessage("つばの摩擦係数 μc"),
    "Collar_Hint": MessageLookupByLibrary.simpleMessage(
      "スラスト軸受で受ける場合は、つばの直径を 0 のままにしてください。平面つばに比べて摩擦は無視できます。",
    ),
    "Collar_Torque": MessageLookupByLibrary.simpleMessage("つばのトルク"),
    "Combined_Loading_at_a_Point": MessageLookupByLibrary.simpleMessage(
      "一点における組合せ荷重",
    ),
    "Compliance_Matrix_S": MessageLookupByLibrary.simpleMessage(
      "コンプライアンスマトリクス S",
    ),
    "Composite_Failure_Criteria": MessageLookupByLibrary.simpleMessage(
      "複合材料の破損基準（Tsai-Hill / Tsai-Wu）",
    ),
    "Composite_Material": MessageLookupByLibrary.simpleMessage("複合材料"),
    "Composite_Wall_Conduction": MessageLookupByLibrary.simpleMessage(
      "多層壁の熱伝導",
    ),
    "Conductivity_k": MessageLookupByLibrary.simpleMessage("熱伝導率 k"),
    "Constitutive_relation_of_linear_elastic_material":
        MessageLookupByLibrary.simpleMessage("線形弾性材料の構成則"),
    "Contact_Pressure_P": MessageLookupByLibrary.simpleMessage("接触圧力、p"),
    "Contact_Stress_Est": MessageLookupByLibrary.simpleMessage("接触応力、σc（推定値）"),
    "Contributing_Frequencies": MessageLookupByLibrary.simpleMessage("寄与する振動数"),
    "Copied": MessageLookupByLibrary.simpleMessage("コピーしました"),
    "Copied_Value": m2,
    "Copy": MessageLookupByLibrary.simpleMessage("コピー"),
    "Copy_Result": MessageLookupByLibrary.simpleMessage("結果をコピー"),
    "Corrected_Length_Lc": MessageLookupByLibrary.simpleMessage("修正長さ Lc"),
    "CountdownDays": MessageLookupByLibrary.simpleMessage("Countdown Days"),
    "Counter_Flow": MessageLookupByLibrary.simpleMessage("向流"),
    "Critical_Speed_Footnote": MessageLookupByLibrary.simpleMessage(
      "ダンカレーの式は常に低めの値を与えるため、表示される危険速度は安全側です。運転速度とは十分な余裕をとってください。",
    ),
    "Critical_Speed_Nc": MessageLookupByLibrary.simpleMessage("危険速度, Nc"),
    "Cross_Section": MessageLookupByLibrary.simpleMessage("断面"),
    "Deflection": MessageLookupByLibrary.simpleMessage("たわみ"),
    "Deflection_Delta": MessageLookupByLibrary.simpleMessage("たわみ、δ"),
    "Deflections_and_slopes_of_cantilever_beams":
        MessageLookupByLibrary.simpleMessage("片持ち梁のたわみとたわみ角"),
    "Deflections_and_slopes_of_simple_beams":
        MessageLookupByLibrary.simpleMessage("単純梁のたわみとたわみ角"),
    "Delete": MessageLookupByLibrary.simpleMessage("削除"),
    "Delete_Project_Description": MessageLookupByLibrary.simpleMessage(
      "この端末からプロジェクトと保存された入力値を削除します。",
    ),
    "Delete_Project_Question": MessageLookupByLibrary.simpleMessage(
      "このプロジェクトを削除しますか？",
    ),
    "Density": MessageLookupByLibrary.simpleMessage("密度"),
    "Desc_Beam_Analysis": MessageLookupByLibrary.simpleMessage(
      "オイラー・ベルヌーイ要素を用いた変位法（直接剛性法）で解いています。静定のはりに加えて、一端固定・他端支持のはり、両端固定のはり、支点を内側に寄せた張り出しはりのように、つり合いだけでは解けない場合も扱えます。",
    ),
    "Desc_Beam_Natural_Frequency": MessageLookupByLibrary.simpleMessage(
      "断面・長さ・材料から求める一様はりの曲げ固有振動数。5種類の支持条件について、1次から3次までのモードを示します。",
    ),
    "Desc_Beam_Supports": MessageLookupByLibrary.simpleMessage(
      "まず支持条件を選び、次にはりが受ける荷重を入力します。集中荷重、等分布・三角形・台形の分布荷重、そして集中モーメントは自由に組み合わせられます。",
    ),
    "Desc_Bearing_Life": MessageLookupByLibrary.simpleMessage(
      "カタログの動基本定格荷重C、動等価荷重P、回転速度nから基本定格寿命を算出します：L10 = (C/P)^p。",
    ),
    "Desc_Belt_Drive": MessageLookupByLibrary.simpleMessage(
      "オープンベルト（またはピッチ径を用いたローラーチェーン）伝動の幾何形状：速度比、概算ベルト長さ、プーリーの巻き付け角。",
    ),
    "Desc_Bolt_Grades": MessageLookupByLibrary.simpleMessage(
      "ISO 898-1 のメートルねじ強度区分と SAE J429 のインチねじ強度区分について、保証応力・降伏強さ・引張強さと、各サイズ・区分で得られる締付軸力および締付トルクをまとめた表です。締付軸力とトルクは表中の強度から計算しているため、両者が食い違うことはありません。",
    ),
    "Desc_Bolt_Preload": MessageLookupByLibrary.simpleMessage(
      "簡易トルク・張力式を用いて、目標のボルト初期張力を得るために必要な締付けトルクを推定します。",
    ),
    "Desc_Composite_Wall": MessageLookupByLibrary.simpleMessage(
      "多層平板壁の一次元定常熱伝導。各層の熱抵抗 t/k と、両面の任意の対流熱抵抗 1/h を直列に加算し、熱通過率 U、熱流量、各界面の温度を求めます。",
    ),
    "Desc_Fillet_Weld": MessageLookupByLibrary.simpleMessage(
      "脚長w、有効長さLの隅肉溶接ののど断面に生じるせん断応力を、のど断面を破断面と仮定して求めます（一般的な簡易法）。",
    ),
    "Desc_Fin_Efficiency": MessageLookupByLibrary.simpleMessage(
      "一様断面の矩形直立フィンを、断熱先端と修正長さ Lc = L + t/2 で解きます：m = √(2h/kt)、η = tanh(mLc)/(mLc)。",
    ),
    "Desc_Lmtd": MessageLookupByLibrary.simpleMessage(
      "4つの出入口温度から対数平均温度差を求め、所定の交換熱量に必要な伝熱面積 A = Q/(U·ΔT_lm) を算出します。向流では各入口と反対側の出口が、並流では2つの入口が対になります。",
    ),
    "Desc_Pipe_Pressure_Drop": MessageLookupByLibrary.simpleMessage(
      "満管流れに対するダルシー・ワイスバッハの損失水頭と圧力損失：h = f·(L/D)·V²/2g。摩擦係数はコールブルックの式から求め、継手類の損失は ΣK 個の速度水頭として加算します。",
    ),
    "Desc_Pipe_Schedules": MessageLookupByLibrary.simpleMessage(
      "ASME B36.10M 鋼管の外径・肉厚・内径。NPS 1/8 から 24、スケジュール 10・40・80・160。内径と流路断面積は記載の外径と肉厚から計算しています。",
    ),
    "Desc_Power_Screw": MessageLookupByLibrary.simpleMessage(
      "送りねじで荷重を上げ下げするのに必要なトルク、効率、そしてブレーキなしで荷重を保持できるかどうかを求めます。ジャッキ、万力、クランプ、工作機械の送りねじが対象です。",
    ),
    "Desc_Press_Fit": MessageLookupByLibrary.simpleMessage(
      "同一材料の中実軸をハブに圧入した場合の接触圧力と周方向応力を求めます（一般的な簡易ケース — ポアソン比は相殺されます）。",
    ),
    "Desc_Pump_Fan_Power": MessageLookupByLibrary.simpleMessage(
      "ポンプ・ファンに必要な動力：流体には P = Δp·Q が与えられ、原動機はこれを効率で除した動力を供給する必要があります。圧力上昇は送液流体のヘッドとしても表示します。",
    ),
    "Desc_Reynolds_Number": MessageLookupByLibrary.simpleMessage(
      "円管内流れのレイノルズ数 Re = ρVD/μ と、層流・遷移・乱流のいずれに当たるかを求めます。流速と体積流量はどちらか一方を入力すれば、もう一方も算出されます。",
    ),
    "Desc_Section_Properties": MessageLookupByLibrary.simpleMessage(
      "梁の曲げおよび応力計算に用いる図心まわりの幾何学的特性を計算します。x軸は図心を通る水平軸、y軸は図心を通る垂直軸です。",
    ),
    "Desc_Shaft_Critical_Speed": MessageLookupByLibrary.simpleMessage(
      "支間の任意の位置にロータを1個支持する軸の一次危険速度。ロータの振れ回りと軸自身の分布質量をダンカレーの式で合成します。",
    ),
    "Desc_Shaft_Fatigue": MessageLookupByLibrary.simpleMessage(
      "変動曲げとねじりの組合せを受ける軸の最小直径を、修正エネルギー説／修正グッドマン基準（シグリー）を用いて求めます。完全両振り曲げ・一定トルクの軸（よくあるケース）では平均モーメント／トルクを0のままにしてください。",
    ),
    "Desc_Spring_Design": MessageLookupByLibrary.simpleMessage(
      "丸線コイル圧縮ばねのばね指数、ワール応力補正係数、ばね定数、および推定基本固有振動数（両端固定）を求めます。",
    ),
    "Desc_Spur_Gear": MessageLookupByLibrary.simpleMessage(
      "20°並歯インボリュート平歯車対：ピッチ円直径、軸間距離、および基本（ルイス式）曲げ応力と簡易接触応力推定値。完全なAGMA設計検証ではありません。",
    ),
    "Desc_Standard_Sections": MessageLookupByLibrary.simpleMessage(
      "標準的な構造用形鋼の公称寸法と断面性能です。断面係数と断面二次半径は掲載の断面積と断面二次モーメントから導出しているため、両者と整合します。",
    ),
    "Desc_Tolerance_Stackup": MessageLookupByLibrary.simpleMessage(
      "公差をもつ寸法の連なりを一次元で積み上げ、ワーストケース法と統計法(RSS)の両方で計算します。すきまの上限と下限、負になり得るかどうか、どの寸法がばらつきの大半を生むかを示します。",
    ),
    "Desc_Torsional_Natural_Frequency": MessageLookupByLibrary.simpleMessage(
      "丸軸のねじり基本固有振動数。一端固定でロータ1個の場合と、自由軸にロータ2個の場合に対応します。",
    ),
    "Desc_Truss_Determinacy": MessageLookupByLibrary.simpleMessage(
      "静定な平面トラスには 部材数 + 反力数 = 2 × 節点数 が必要です。ピン支点とローラー支点を少なくとも1つずつ設けてください。",
    ),
    "Description": MessageLookupByLibrary.simpleMessage("説明"),
    "Description_and_Formulas": MessageLookupByLibrary.simpleMessage("説明と計算式"),
    "Diameter_D": MessageLookupByLibrary.simpleMessage("直径、d"),
    "Diametral_Interference": MessageLookupByLibrary.simpleMessage("直径しめしろ、δ"),
    "Displacement": MessageLookupByLibrary.simpleMessage("変位"),
    "Display_Format": MessageLookupByLibrary.simpleMessage("表示形式"),
    "Double_Shear": MessageLookupByLibrary.simpleMessage("二面せん断"),
    "Drag_Along_Line": m3,
    "Drill_Tap_Chart": MessageLookupByLibrary.simpleMessage("ドリル・タップ表"),
    "Drill_Tap_Footnote": MessageLookupByLibrary.simpleMessage(
      "径の単位はmmです。インチドリルは呼び径の下にmm換算値を表示します。下穴径は鋼材でおよそ75%のねじ山かかりを想定し、メートルばか穴はISO 273（精級・並級）に準拠しています。行をタップするとコピーできます。",
    ),
    "Driving_Torque_T1": MessageLookupByLibrary.simpleMessage("駆動トルク、T1"),
    "Dynamic_Load_Rating_C": MessageLookupByLibrary.simpleMessage("動基本定格荷重、C"),
    "Dynamic_Viscosity": MessageLookupByLibrary.simpleMessage("粘度 μ"),
    "E_Modulus": MessageLookupByLibrary.simpleMessage("E（弾性係数）"),
    "Effective_Inertia_J": MessageLookupByLibrary.simpleMessage(
      "等価慣性モーメント, Jeff",
    ),
    "Effective_Length_L": MessageLookupByLibrary.simpleMessage("有効長さ、L"),
    "Efficiency_Eta": MessageLookupByLibrary.simpleMessage("効率 η（%）"),
    "Elastic": MessageLookupByLibrary.simpleMessage("弾性"),
    "Elastic_Coefficient_Cp": MessageLookupByLibrary.simpleMessage(
      "弾性係数、Cp（√MPa）",
    ),
    "Elastic_Deflection": MessageLookupByLibrary.simpleMessage("弾性たわみ"),
    "Elastic_Modulus_E": MessageLookupByLibrary.simpleMessage("弾性係数、E"),
    "End_Approach_1": MessageLookupByLibrary.simpleMessage("端部温度差 ΔT1"),
    "End_Approach_2": MessageLookupByLibrary.simpleMessage("端部温度差 ΔT2"),
    "End_Condition": MessageLookupByLibrary.simpleMessage("端部条件"),
    "Endurance_Limit_Se": MessageLookupByLibrary.simpleMessage("疲労限度、Se"),
    "Engineering_Constants": MessageLookupByLibrary.simpleMessage("工学定数"),
    "Enter_Fx_Fy_Components": MessageLookupByLibrary.simpleMessage(
      "各力のFx成分とFy成分を入力してください（N）",
    ),
    "Equivalent_Load_P": MessageLookupByLibrary.simpleMessage("動等価荷重、P"),
    "Equivalent_Shaft_Speed": MessageLookupByLibrary.simpleMessage("相当回転速度"),
    "Err_Active_Coils_Positive": MessageLookupByLibrary.simpleMessage(
      "有効巻数は正の値である必要があります。",
    ),
    "Err_Add_One_Member": MessageLookupByLibrary.simpleMessage(
      "部材を少なくとも1つ追加してください。",
    ),
    "Err_Beam_Load_Incomplete": MessageLookupByLibrary.simpleMessage(
      "各荷重の項目をすべて入力するか、その荷重を削除してください。",
    ),
    "Err_C_Positive": MessageLookupByLibrary.simpleMessage(
      "動基本定格荷重Cは正の値である必要があります。",
    ),
    "Err_Center_Distance_Positive": MessageLookupByLibrary.simpleMessage(
      "軸間距離は正の値である必要があります。",
    ),
    "Err_Dimensions_Positive": MessageLookupByLibrary.simpleMessage(
      "寸法はゼロより大きい必要があります。",
    ),
    "Err_Enter_Beam_Frequency_Inputs": MessageLookupByLibrary.simpleMessage(
      "E、I、A、長さ、密度を入力してください。",
    ),
    "Err_Enter_C_P_N": MessageLookupByLibrary.simpleMessage("C、P、nを入力してください。"),
    "Err_Enter_Critical_Speed_Inputs": MessageLookupByLibrary.simpleMessage(
      "E、軸径、支間、ロータ質量、ロータ位置を入力してください。",
    ),
    "Err_Enter_D1_D2_C_N1": MessageLookupByLibrary.simpleMessage(
      "d1、d2、C、n1を入力してください。",
    ),
    "Err_Enter_D_BigD_Na_G": MessageLookupByLibrary.simpleMessage(
      "d、D、Na、Gを入力してください。",
    ),
    "Err_Enter_F_D": MessageLookupByLibrary.simpleMessage("Fとdを入力してください。"),
    "Err_Enter_Fin_Inputs": MessageLookupByLibrary.simpleMessage(
      "フィン形状、熱伝導率、熱伝達率、温度を入力してください。",
    ),
    "Err_Enter_Layer_Values": MessageLookupByLibrary.simpleMessage(
      "各層に厚さと熱伝導率が必要です。",
    ),
    "Err_Enter_Lmtd_Inputs": MessageLookupByLibrary.simpleMessage(
      "4つの温度、U、交換熱量を入力してください。",
    ),
    "Err_Enter_Module_N1_N2_Face": MessageLookupByLibrary.simpleMessage(
      "モジュール、N1、N2、歯幅を入力してください。",
    ),
    "Err_Enter_Moment_Or_Torque": MessageLookupByLibrary.simpleMessage(
      "曲げモーメントまたはトルクを少なくとも1つ入力してください。",
    ),
    "Err_Enter_One_Load": MessageLookupByLibrary.simpleMessage(
      "荷重を少なくとも1つ入力してください。",
    ),
    "Err_Enter_Pipe_Inputs": MessageLookupByLibrary.simpleMessage(
      "管径、管長、流量、流体物性を入力してください。",
    ),
    "Err_Enter_Pump_Inputs": MessageLookupByLibrary.simpleMessage(
      "流量、圧力上昇、密度、効率を入力してください。",
    ),
    "Err_Enter_R_Ro_Delta_E": MessageLookupByLibrary.simpleMessage(
      "r、ro、δ、Eを入力してください。",
    ),
    "Err_Enter_Reynolds_Inputs": MessageLookupByLibrary.simpleMessage(
      "管径、流体物性、および流速か流量のいずれかを入力してください。",
    ),
    "Err_Enter_Se_Sut": MessageLookupByLibrary.simpleMessage(
      "SeとSutを入力してください。",
    ),
    "Err_Enter_Torsional_Inputs": MessageLookupByLibrary.simpleMessage(
      "G、軸径、軸長さ、ロータ慣性モーメントを入力してください。",
    ),
    "Err_Enter_W_L_F": MessageLookupByLibrary.simpleMessage("w、L、Fを入力してください。"),
    "Err_Enter_Wall_Inputs": MessageLookupByLibrary.simpleMessage(
      "壁面積と両側の温度を入力してください。",
    ),
    "Err_F_D_Positive": MessageLookupByLibrary.simpleMessage(
      "Fとdは正の値である必要があります。",
    ),
    "Err_Face_Width_Positive": MessageLookupByLibrary.simpleMessage(
      "歯幅は正の値である必要があります。",
    ),
    "Err_Input_Speed_Positive": MessageLookupByLibrary.simpleMessage(
      "入力回転速度は正の値である必要があります。",
    ),
    "Err_Interface_Radius_Positive": MessageLookupByLibrary.simpleMessage(
      "接触半径は正の値である必要があります。",
    ),
    "Err_Interference_Positive": MessageLookupByLibrary.simpleMessage(
      "しめしろは正の値である必要があります。",
    ),
    "Err_Loads_Non_Negative": MessageLookupByLibrary.simpleMessage(
      "荷重は負の値にできません。",
    ),
    "Err_Member_Unknown_Joint": MessageLookupByLibrary.simpleMessage(
      "ある部材が不明な節点を参照しています。",
    ),
    "Err_Module_Positive": MessageLookupByLibrary.simpleMessage(
      "モジュールは正の値である必要があります。",
    ),
    "Err_Modulus_Positive": MessageLookupByLibrary.simpleMessage(
      "弾性係数は正の値である必要があります。",
    ),
    "Err_Nut_Factor_Positive": MessageLookupByLibrary.simpleMessage(
      "ナット係数Kは正の値である必要があります。",
    ),
    "Err_P_Positive": MessageLookupByLibrary.simpleMessage(
      "動等価荷重Pは正の値である必要があります。",
    ),
    "Err_Power_Screw_Inputs": MessageLookupByLibrary.simpleMessage(
      "呼び径、ピッチ、軸方向荷重を入力してください。",
    ),
    "Err_Pulley_Positive": MessageLookupByLibrary.simpleMessage(
      "プーリー径は正の値である必要があります。",
    ),
    "Err_Result_Not_Savable": MessageLookupByLibrary.simpleMessage(
      "この結果に対応するツールがないため保存できません。",
    ),
    "Err_Rotor_Position_Range": MessageLookupByLibrary.simpleMessage(
      "ロータは支持点を避けて軸上に配置してください。",
    ),
    "Err_Se_Sut_Positive": MessageLookupByLibrary.simpleMessage(
      "SeとSutは正の値である必要があります。",
    ),
    "Err_Second_Rotor_Inertia": MessageLookupByLibrary.simpleMessage(
      "第2ロータの慣性モーメントを入力してください。",
    ),
    "Err_Shear_Modulus_Positive": MessageLookupByLibrary.simpleMessage(
      "横弾性係数は正の値である必要があります。",
    ),
    "Err_Span_Positive": MessageLookupByLibrary.simpleMessage(
      "スパンはゼロより大きい必要があります。",
    ),
    "Err_Speed_Positive": MessageLookupByLibrary.simpleMessage(
      "回転速度は正の値である必要があります。",
    ),
    "Err_Stackup_Dimension": MessageLookupByLibrary.simpleMessage(
      "すべての寸法に基準寸法と上下の寸法差を入力してください。",
    ),
    "Err_Stackup_Two_Rows": MessageLookupByLibrary.simpleMessage(
      "積み上げには 2 つ以上の寸法が必要です。",
    ),
    "Err_Target_FoS_Positive": MessageLookupByLibrary.simpleMessage(
      "目標安全率は正の値である必要があります。",
    ),
    "Err_Truss_Two_Joints": MessageLookupByLibrary.simpleMessage(
      "トラスには少なくとも2つの節点が必要です。",
    ),
    "Err_Values_Positive": MessageLookupByLibrary.simpleMessage(
      "すべての値は0より大きい必要があります。",
    ),
    "Err_W_L_F_Positive": MessageLookupByLibrary.simpleMessage(
      "w、L、Fは正の値である必要があります。",
    ),
    "Err_Wire_Coil_Positive": MessageLookupByLibrary.simpleMessage(
      "線径とコイル径は正の値である必要があります。",
    ),
    "Export_Report": MessageLookupByLibrary.simpleMessage("レポートを出力"),
    "Express_Scan": MessageLookupByLibrary.simpleMessage("Express Scan"),
    "Extreme_Fibre_C": MessageLookupByLibrary.simpleMessage("中立軸から縁までの距離 c"),
    "Extreme_Fibre_Hint": MessageLookupByLibrary.simpleMessage(
      "任意 — c を入力すると曲げ応力も出力されます。",
    ),
    "Face_Width_F": MessageLookupByLibrary.simpleMessage("歯幅、F"),
    "Factor_of_Safety": MessageLookupByLibrary.simpleMessage("安全率"),
    "Failure_criteria_von_Mises_Tresca": MessageLookupByLibrary.simpleMessage(
      "破損基準（フォン・ミーゼス & トレスカ）",
    ),
    "Family_Angle": MessageLookupByLibrary.simpleMessage("山形鋼"),
    "Family_Channel": MessageLookupByLibrary.simpleMessage("溝形鋼"),
    "Family_HEB": MessageLookupByLibrary.simpleMessage("HEB形鋼"),
    "Family_HSS": MessageLookupByLibrary.simpleMessage("角形鋼管"),
    "Family_IPE": MessageLookupByLibrary.simpleMessage("IPE形鋼"),
    "Family_Pipe": MessageLookupByLibrary.simpleMessage("鋼管"),
    "Family_W": MessageLookupByLibrary.simpleMessage("W形鋼"),
    "Fatigue_Safety_Factor": MessageLookupByLibrary.simpleMessage(
      "疲労安全率（修正グッドマン法）",
    ),
    "Favorites": MessageLookupByLibrary.simpleMessage("お気に入り"),
    "Feedback": MessageLookupByLibrary.simpleMessage("フィードバック"),
    "Fillet_Weld_Strength": MessageLookupByLibrary.simpleMessage("隅肉溶接の強度"),
    "Film_Coefficient_h": MessageLookupByLibrary.simpleMessage("熱伝達率 h"),
    "Film_Optional_Note": MessageLookupByLibrary.simpleMessage(
      "熱伝達率を空欄にすると、その側の温度は壁表面温度として扱われます。",
    ),
    "Fin_Effectiveness": MessageLookupByLibrary.simpleMessage("フィン有効度 εf"),
    "Fin_Efficiency": MessageLookupByLibrary.simpleMessage("フィン効率"),
    "Fin_Efficiency_Eta": MessageLookupByLibrary.simpleMessage("フィン効率 ηf"),
    "Fin_Heat_Flow": MessageLookupByLibrary.simpleMessage("フィン放熱量"),
    "Fin_Length_L": MessageLookupByLibrary.simpleMessage("フィン長さ L"),
    "Fin_Parameter_m": MessageLookupByLibrary.simpleMessage("フィンパラメータ m"),
    "Fin_Surface_Area": MessageLookupByLibrary.simpleMessage("フィン表面積"),
    "Fin_Thickness_t": MessageLookupByLibrary.simpleMessage("フィン厚さ t"),
    "Fin_Width_w": MessageLookupByLibrary.simpleMessage("フィン幅 w"),
    "FinanceGo": MessageLookupByLibrary.simpleMessage("Finance Go"),
    "Find_Power": MessageLookupByLibrary.simpleMessage("動力を求める"),
    "Find_Torque": MessageLookupByLibrary.simpleMessage("トルクを求める"),
    "Fit": MessageLookupByLibrary.simpleMessage("はめあい"),
    "Fits_Footnote": MessageLookupByLibrary.simpleMessage(
      "1〜500mmの穴基準はめあいです。各セルは基準寸法からのマイクロメートル単位で、上の許容差を下の許容差の上に表示しています。負のすきまはしめしろを意味します。帯は下限から上限まで続きます。軸のはめあいc、s、uは許容差がより細かいサイズ帯に分かれるため掲載していません。",
    ),
    "Fits_Tolerances": MessageLookupByLibrary.simpleMessage("はめあい・公差（ISO 286）"),
    "Fixing_Moment_At_X": m4,
    "Flange_Thickness": MessageLookupByLibrary.simpleMessage("フランジ厚"),
    "Flexural_Rigidity_EI": MessageLookupByLibrary.simpleMessage("曲げ剛性, EI"),
    "Flexure_formula_of_beam": MessageLookupByLibrary.simpleMessage("梁の曲げ公式"),
    "Flow_Area": MessageLookupByLibrary.simpleMessage("流路断面積"),
    "Flow_Arrangement": MessageLookupByLibrary.simpleMessage("流れ方式"),
    "Flow_Laminar": MessageLookupByLibrary.simpleMessage("層流"),
    "Flow_Rate_Q": MessageLookupByLibrary.simpleMessage("流量 Q"),
    "Flow_Regime": MessageLookupByLibrary.simpleMessage("流れの状態"),
    "Flow_Transitional": MessageLookupByLibrary.simpleMessage("遷移流"),
    "Flow_Turbulent": MessageLookupByLibrary.simpleMessage("乱流"),
    "Flow_Velocity_V": MessageLookupByLibrary.simpleMessage("流速 V"),
    "Fluid_Presets": MessageLookupByLibrary.simpleMessage("流体プリセット"),
    "Fluids_and_Thermal": MessageLookupByLibrary.simpleMessage("流体・伝熱"),
    "Force": MessageLookupByLibrary.simpleMessage("力"),
    "Force_displacement_relation_of_bar": MessageLookupByLibrary.simpleMessage(
      "棒の力-変位関係",
    ),
    "Forces": MessageLookupByLibrary.simpleMessage("力"),
    "Format_Auto": MessageLookupByLibrary.simpleMessage("自動"),
    "Format_Decimal": MessageLookupByLibrary.simpleMessage("小数"),
    "Format_Engineering": MessageLookupByLibrary.simpleMessage("工学表記"),
    "Format_Scientific": MessageLookupByLibrary.simpleMessage("指数表記"),
    "Formula": MessageLookupByLibrary.simpleMessage("計算式"),
    "Formulas": MessageLookupByLibrary.simpleMessage("計算式"),
    "Friction_Factor_f": MessageLookupByLibrary.simpleMessage("管摩擦係数 f"),
    "Friction_Head_Loss": MessageLookupByLibrary.simpleMessage("摩擦損失水頭"),
    "From": MessageLookupByLibrary.simpleMessage("起点"),
    "Full_Span_UDL_W": MessageLookupByLibrary.simpleMessage("全スパン等分布荷重、w"),
    "G_Shear_Modulus": MessageLookupByLibrary.simpleMessage("G（横弾性係数）"),
    "Gear_Pitch_Diameter_D2": MessageLookupByLibrary.simpleMessage(
      "ギヤピッチ円直径、d2",
    ),
    "Gear_Ratio": MessageLookupByLibrary.simpleMessage("歯車比"),
    "Gear_Teeth_N2": MessageLookupByLibrary.simpleMessage("ギヤ歯数、N2"),
    "General_stress_calculation": MessageLookupByLibrary.simpleMessage(
      "一般応力計算",
    ),
    "Grade_Class": MessageLookupByLibrary.simpleMessage("強度区分"),
    "Grid_View": MessageLookupByLibrary.simpleMessage("グリッド表示"),
    "Group_Building": MessageLookupByLibrary.simpleMessage("建築材料"),
    "Group_Insulation": MessageLookupByLibrary.simpleMessage("断熱材"),
    "Group_Metal": MessageLookupByLibrary.simpleMessage("金属"),
    "Heat_Duty_Q": MessageLookupByLibrary.simpleMessage("交換熱量 Q"),
    "Heat_Exchanger_LMTD": MessageLookupByLibrary.simpleMessage(
      "熱交換器（対数平均温度差）",
    ),
    "Heat_Flow_Q": MessageLookupByLibrary.simpleMessage("熱流量 Q"),
    "Heat_Flux": MessageLookupByLibrary.simpleMessage("熱流束 q\""),
    "Height_H": MessageLookupByLibrary.simpleMessage("高さ h"),
    "Helical_Compression_Spring": MessageLookupByLibrary.simpleMessage(
      "コイル圧縮ばね",
    ),
    "Help_Assumptions": MessageLookupByLibrary.simpleMessage("前提と適用条件"),
    "Help_References": MessageLookupByLibrary.simpleMessage("出典"),
    "Help_Symbols": MessageLookupByLibrary.simpleMessage("記号"),
    "Help_Unavailable": MessageLookupByLibrary.simpleMessage(
      "このツールの詳しい説明はまだありません。",
    ),
    "History": MessageLookupByLibrary.simpleMessage("履歴"),
    "Holds_With_Collar": MessageLookupByLibrary.simpleMessage("つばの摩擦を含めて保持する"),
    "Hole_um": MessageLookupByLibrary.simpleMessage("穴 (µm)"),
    "Hot_Inlet": MessageLookupByLibrary.simpleMessage("高温側入口"),
    "Hot_Outlet": MessageLookupByLibrary.simpleMessage("高温側出口"),
    "Hot_Stream_Range": MessageLookupByLibrary.simpleMessage("高温側温度変化"),
    "Hub_Hoop_Stress": MessageLookupByLibrary.simpleMessage("ハブ穴の周方向応力、σt"),
    "Hub_Outer_Radius_Ro": MessageLookupByLibrary.simpleMessage("ハブ外半径、ro"),
    "Hydraulic_Power": MessageLookupByLibrary.simpleMessage("水動力"),
    "Image_Guru": MessageLookupByLibrary.simpleMessage("Image Guru"),
    "Imperial_US": MessageLookupByLibrary.simpleMessage("ヤード・ポンド法 (US)"),
    "Include_Shaft_Mass": MessageLookupByLibrary.simpleMessage("軸自身の質量を考慮する"),
    "Input_Speed_N1": MessageLookupByLibrary.simpleMessage("入力回転速度、n1"),
    "Inputs": MessageLookupByLibrary.simpleMessage("入力"),
    "Inside_Air": MessageLookupByLibrary.simpleMessage("内側流体"),
    "Inside_Diameter_D": MessageLookupByLibrary.simpleMessage("内径 D"),
    "Inside_Film_Coefficient": MessageLookupByLibrary.simpleMessage(
      "内側熱伝達率 hi",
    ),
    "Inside_Temperature": MessageLookupByLibrary.simpleMessage("内側温度"),
    "Instant_Face": MessageLookupByLibrary.simpleMessage("Instant Face"),
    "Interface_Radius_R": MessageLookupByLibrary.simpleMessage("接触半径、r"),
    "Isothermal_Max_Heat_Flow": MessageLookupByLibrary.simpleMessage(
      "等温フィンの理論最大値",
    ),
    "Isotropic_material": MessageLookupByLibrary.simpleMessage("等方性材料"),
    "Joints": MessageLookupByLibrary.simpleMessage("節点"),
    "Kf_Bending": MessageLookupByLibrary.simpleMessage("Kf（曲げ）"),
    "Kfs_Torsion": MessageLookupByLibrary.simpleMessage("Kfs（ねじり）"),
    "Kinematic_Viscosity": MessageLookupByLibrary.simpleMessage("動粘度 ν"),
    "L10_Hours": MessageLookupByLibrary.simpleMessage("L10（時間）"),
    "L10_Million_Revolutions": MessageLookupByLibrary.simpleMessage(
      "L10（百万回転）",
    ),
    "Lamina_Constants": MessageLookupByLibrary.simpleMessage("一層の定数"),
    "Lamina_engineering_constants": MessageLookupByLibrary.simpleMessage(
      "一層の工学定数",
    ),
    "Lamina_stressstrain": MessageLookupByLibrary.simpleMessage("一層の応力/ひずみ"),
    "Laminate_3D_properties": MessageLookupByLibrary.simpleMessage("積層板の3D特性"),
    "Laminate_plane_properties": MessageLookupByLibrary.simpleMessage(
      "積層板の面内特性",
    ),
    "Laminate_stressstrain": MessageLookupByLibrary.simpleMessage("積層板の応力/ひずみ"),
    "Language": MessageLookupByLibrary.simpleMessage("言語"),
    "Large_Pulley_Diameter_D2": MessageLookupByLibrary.simpleMessage(
      "大プーリー径、d2",
    ),
    "Layer_Number": m5,
    "Layer_Resistances": MessageLookupByLibrary.simpleMessage("各層の熱抵抗"),
    "Layer_Thickness": MessageLookupByLibrary.simpleMessage("層厚"),
    "Layup_Angle": MessageLookupByLibrary.simpleMessage("積層角度"),
    "Layup_Sequence": MessageLookupByLibrary.simpleMessage("積層構成"),
    "Lead_Angle_Lambda": MessageLookupByLibrary.simpleMessage("リード角 λ"),
    "Lead_L": MessageLookupByLibrary.simpleMessage("リード"),
    "Left_Reaction_RA": MessageLookupByLibrary.simpleMessage("左反力、RA"),
    "Left_Support_Position": MessageLookupByLibrary.simpleMessage("左支点の位置"),
    "Leg_Size_W": MessageLookupByLibrary.simpleMessage("脚長、w"),
    "Lewis_Form_Factor_Y": MessageLookupByLibrary.simpleMessage(
      "ルイス歯形係数、Y（ピニオン）",
    ),
    "List_View": MessageLookupByLibrary.simpleMessage("リスト表示"),
    "Load_Case": MessageLookupByLibrary.simpleMessage("荷重ケース"),
    "Load_Couple_M": MessageLookupByLibrary.simpleMessage("モーメント M（反時計回り +）"),
    "Load_Ends_At": MessageLookupByLibrary.simpleMessage("終了位置"),
    "Load_Fx": MessageLookupByLibrary.simpleMessage("荷重 Fx"),
    "Load_Fy": MessageLookupByLibrary.simpleMessage("荷重 Fy"),
    "Load_Intensity_End": MessageLookupByLibrary.simpleMessage("終了位置の強さ"),
    "Load_Intensity_Start": MessageLookupByLibrary.simpleMessage("開始位置の強さ"),
    "Load_Magnitude_P": MessageLookupByLibrary.simpleMessage("大きさ P（下向き +）"),
    "Load_Position_X": MessageLookupByLibrary.simpleMessage("位置 x"),
    "Load_Starts_At": MessageLookupByLibrary.simpleMessage("開始位置"),
    "Load_Type": MessageLookupByLibrary.simpleMessage("荷重タイプ"),
    "Load_Type_Couple": MessageLookupByLibrary.simpleMessage("モーメント"),
    "Load_Type_Distributed": MessageLookupByLibrary.simpleMessage("分布"),
    "Load_Type_Point": MessageLookupByLibrary.simpleMessage("集中"),
    "Log_Mean_Delta_T": MessageLookupByLibrary.simpleMessage("対数平均温度差"),
    "ME_Toolkit": MessageLookupByLibrary.simpleMessage("ME Toolkit"),
    "Machine_Design": MessageLookupByLibrary.simpleMessage("機械設計"),
    "Major_Diameter_D": MessageLookupByLibrary.simpleMessage("呼び径 d"),
    "Mass_Per_Length": MessageLookupByLibrary.simpleMessage("単位長さ質量, ρA"),
    "Material_Density_Default_Steel": MessageLookupByLibrary.simpleMessage(
      "材料密度（既定値は鋼）",
    ),
    "Material_Presets": MessageLookupByLibrary.simpleMessage("材料プリセット"),
    "Materials_Science_Engineering": MessageLookupByLibrary.simpleMessage(
      "材料科学・工学",
    ),
    "Maximum_Bending_Moment": MessageLookupByLibrary.simpleMessage("最大曲げモーメント"),
    "Maximum_Downward_Deflection": MessageLookupByLibrary.simpleMessage(
      "最大下向きたわみ",
    ),
    "Maximum_Hogging_Moment": MessageLookupByLibrary.simpleMessage(
      "最大負曲げモーメント",
    ),
    "Maximum_Sagging_Moment": MessageLookupByLibrary.simpleMessage(
      "最大正曲げモーメント",
    ),
    "Maximum_Shear": MessageLookupByLibrary.simpleMessage("最大せん断力"),
    "Maybe_Later": MessageLookupByLibrary.simpleMessage("後で"),
    "Mean_Coil_Diameter_D": MessageLookupByLibrary.simpleMessage("平均コイル径、D"),
    "Mean_Diameter_Dm": MessageLookupByLibrary.simpleMessage("有効径 dm"),
    "Mean_Moment_Mm": MessageLookupByLibrary.simpleMessage("平均曲げモーメント、Mm"),
    "Mean_Torque_Tm": MessageLookupByLibrary.simpleMessage("平均トルク、Tm"),
    "Mechanical_Engineering": MessageLookupByLibrary.simpleMessage("機械工学"),
    "Mechanics_of_Material": MessageLookupByLibrary.simpleMessage("材料力学"),
    "Member_Forces": MessageLookupByLibrary.simpleMessage(
      "部材力（+ 引張、\\u2212 圧縮）",
    ),
    "Members": MessageLookupByLibrary.simpleMessage("部材"),
    "Metric_Coarse": MessageLookupByLibrary.simpleMessage("メートル並目"),
    "Metric_Fine": MessageLookupByLibrary.simpleMessage("メートル細目"),
    "Metric_SI": MessageLookupByLibrary.simpleMessage("メートル法 (SI)"),
    "Metronome_Go": MessageLookupByLibrary.simpleMessage("Metronome Go"),
    "Minor_Head_Loss": MessageLookupByLibrary.simpleMessage("局部損失水頭"),
    "Minor_Loss_K": MessageLookupByLibrary.simpleMessage("局部損失係数 ΣK"),
    "Mint_Translate": MessageLookupByLibrary.simpleMessage("Mint Translate"),
    "Minus_Tolerance": MessageLookupByLibrary.simpleMessage("下の寸法差, −"),
    "Mode_Number": m6,
    "Module_M": MessageLookupByLibrary.simpleMessage("モジュール、m"),
    "Modulus_E": MessageLookupByLibrary.simpleMessage("弾性係数、E"),
    "Mohrs_Circle_for_Plane_Stress": MessageLookupByLibrary.simpleMessage(
      "平面応力のモールの応力円",
    ),
    "Moments_of_Inertia": MessageLookupByLibrary.simpleMessage("断面二次モーメント"),
    "Moments_of_inertia_of_plane_areas": MessageLookupByLibrary.simpleMessage(
      "平面図形の断面二次モーメント",
    ),
    "MoneyTracker": MessageLookupByLibrary.simpleMessage("Money Tracker"),
    "Money_Tracker": MessageLookupByLibrary.simpleMessage("Money Tracker"),
    "Monoclinic_material": MessageLookupByLibrary.simpleMessage("単斜異方性材料"),
    "More": MessageLookupByLibrary.simpleMessage("その他"),
    "MoreApps": MessageLookupByLibrary.simpleMessage("その他のアプリ"),
    "MyFavourite": MessageLookupByLibrary.simpleMessage("お気に入り"),
    "NASALover": MessageLookupByLibrary.simpleMessage("NASA Lover"),
    "Name": MessageLookupByLibrary.simpleMessage("名前"),
    "Natural_Frequency_Estimate": MessageLookupByLibrary.simpleMessage(
      "固有振動数（推定値）",
    ),
    "Natural_Frequency_F": MessageLookupByLibrary.simpleMessage("固有振動数, f"),
    "New_Project": MessageLookupByLibrary.simpleMessage("新しいプロジェクト"),
    "No_Favorites_Yet": MessageLookupByLibrary.simpleMessage("お気に入りはまだありません"),
    "No_Fluids_Found": MessageLookupByLibrary.simpleMessage("流体が見つかりません"),
    "No_History_Yet": MessageLookupByLibrary.simpleMessage("履歴はまだありません"),
    "No_Matches": MessageLookupByLibrary.simpleMessage("一致する項目がありません"),
    "No_Matches_Description": MessageLookupByLibrary.simpleMessage(
      "別のサイズを試すか、フィルターをクリアしてください。",
    ),
    "No_Materials_Found": MessageLookupByLibrary.simpleMessage("材料が見つかりません"),
    "No_Pipes_Found": MessageLookupByLibrary.simpleMessage("配管サイズが見つかりません"),
    "No_Saved_Projects_Message": MessageLookupByLibrary.simpleMessage(
      "履歴から計算を保存すると、その入力値をここに残せます。",
    ),
    "No_Saved_Projects_Yet": MessageLookupByLibrary.simpleMessage(
      "保存したプロジェクトはまだありません",
    ),
    "No_Sections_Found": MessageLookupByLibrary.simpleMessage("断面が見つかりません"),
    "No_Tools_Found": MessageLookupByLibrary.simpleMessage("ツールが見つかりません"),
    "Node_Position": MessageLookupByLibrary.simpleMessage("節の位置（ロータ1から）"),
    "Nominal_Diameter_D": MessageLookupByLibrary.simpleMessage("呼び径、d"),
    "Nominal_Gap": MessageLookupByLibrary.simpleMessage("基準すきま"),
    "Nominal_Size": MessageLookupByLibrary.simpleMessage("基準寸法"),
    "Nominal_Size_mm": MessageLookupByLibrary.simpleMessage("サイズ (mm)"),
    "None": MessageLookupByLibrary.simpleMessage("なし"),
    "Not_a_number": MessageLookupByLibrary.simpleMessage("数値ではありません"),
    "Note_Polar_Moment": MessageLookupByLibrary.simpleMessage(
      "J = Ix + Iyは断面極二次モーメントです。非円形断面のセントブナンのねじり定数ではありません。",
    ),
    "NovelsHub": MessageLookupByLibrary.simpleMessage("Novels Hub"),
    "Novels_Hub": MessageLookupByLibrary.simpleMessage("Novels Hub"),
    "Nut_Factor_K": MessageLookupByLibrary.simpleMessage(
      "ナット係数、K（既定値0.2 — 無潤滑鋼で一般的。潤滑・めっき品は約0.15、乾燥状態は約0.2〜0.3）",
    ),
    "Onlynote": MessageLookupByLibrary.simpleMessage("Onlynote"),
    "Operating_Force_F": MessageLookupByLibrary.simpleMessage("作動荷重、F"),
    "Optional_For_Bending_Contact": MessageLookupByLibrary.simpleMessage(
      "任意 — 曲げ／接触応力用",
    ),
    "Optional_For_Deflection_Frequency": MessageLookupByLibrary.simpleMessage(
      "任意 — 作動時のたわみ／応力と固有振動数用",
    ),
    "Orthotropic_material": MessageLookupByLibrary.simpleMessage("直交異方性材料"),
    "Output_Speed_N2": MessageLookupByLibrary.simpleMessage("出力回転速度、n2"),
    "Outside_Air": MessageLookupByLibrary.simpleMessage("外側流体"),
    "Outside_Diameter_OD": MessageLookupByLibrary.simpleMessage("外径, OD"),
    "Outside_Film_Coefficient": MessageLookupByLibrary.simpleMessage(
      "外側熱伝達率 ho",
    ),
    "Outside_Temperature": MessageLookupByLibrary.simpleMessage("外側温度"),
    "Overall_Coefficient_U": MessageLookupByLibrary.simpleMessage("総括伝熱係数 U"),
    "Overall_Height": MessageLookupByLibrary.simpleMessage("全高"),
    "PDF_Missing_Characters": MessageLookupByLibrary.simpleMessage(
      "PDFで一部の文字が表示されない場合があります",
    ),
    "P_Load": MessageLookupByLibrary.simpleMessage("P（荷重）"),
    "Parallel_Flow": MessageLookupByLibrary.simpleMessage("並流"),
    "Pick_Fluid": MessageLookupByLibrary.simpleMessage("流体を選択"),
    "Pick_Material": MessageLookupByLibrary.simpleMessage("材料を選択"),
    "Pick_Pipe_Size": MessageLookupByLibrary.simpleMessage("配管サイズを選択"),
    "Pick_Standard_Section": MessageLookupByLibrary.simpleMessage("標準断面を選択"),
    "Pick_Thermal_Material": MessageLookupByLibrary.simpleMessage("材料を選択"),
    "Pin": MessageLookupByLibrary.simpleMessage("ピン支点"),
    "Pinion_Pitch_Diameter_D1": MessageLookupByLibrary.simpleMessage(
      "ピニオンピッチ円直径、d1",
    ),
    "Pinion_Teeth_N1": MessageLookupByLibrary.simpleMessage("ピニオン歯数、N1"),
    "Pipe_Fill_Note": MessageLookupByLibrary.simpleMessage(
      "サイズを選ぶと下の内径が入力されます。",
    ),
    "Pipe_Length_L": MessageLookupByLibrary.simpleMessage("管長さ L"),
    "Pipe_Pressure_Drop": MessageLookupByLibrary.simpleMessage("管路の圧力損失"),
    "Pipe_Schedule": MessageLookupByLibrary.simpleMessage("スケジュール"),
    "Pipe_Schedules": MessageLookupByLibrary.simpleMessage("配管スケジュール"),
    "Pipe_Size_NPS": MessageLookupByLibrary.simpleMessage("NPS"),
    "Pipes_Footnote": MessageLookupByLibrary.simpleMessage(
      "ASME B36.10M の溶接鋼管および継目無鋼管。NPS と DN は呼称であり実寸ではありません。数値が外径(インチ)と一致するのは NPS 14 以上のみです。STD と XS は Sch 40・Sch 80 と一致する場合のみ表示しています。",
    ),
    "Pitch_TPI": MessageLookupByLibrary.simpleMessage("ピッチ / TPI"),
    "Plane_Stresses": MessageLookupByLibrary.simpleMessage("平面応力"),
    "Plane_stresses_transformation": MessageLookupByLibrary.simpleMessage(
      "平面応力の変換",
    ),
    "Plus_Tolerance": MessageLookupByLibrary.simpleMessage("上の寸法差, +"),
    "Point_Load": MessageLookupByLibrary.simpleMessage("集中荷重"),
    "Point_Load_P": MessageLookupByLibrary.simpleMessage("集中荷重、P"),
    "Point_Position_A": MessageLookupByLibrary.simpleMessage("荷重位置、a"),
    "Polar_Area_Moment_J": MessageLookupByLibrary.simpleMessage("断面極二次モーメント、J"),
    "Polar_Moment_Jp": MessageLookupByLibrary.simpleMessage("断面二次極モーメント, Jp"),
    "Power_Lost": MessageLookupByLibrary.simpleMessage("損失動力"),
    "Power_Optional": MessageLookupByLibrary.simpleMessage("動力（任意）"),
    "Power_Screw": MessageLookupByLibrary.simpleMessage("送りねじ・パワースクリュー"),
    "Power_Screw_Note": MessageLookupByLibrary.simpleMessage(
      "Shigley の導出と同じく、単一の平均半径におけるクーロン摩擦を仮定しています。実際の摩擦係数は材料の組合せ、潤滑、ねじの摩耗によって変わり、鋼と青銅の組合せではおおむね 0.10〜0.20 に収まります。これは上の数値の多くよりも広い幅です。",
    ),
    "Precision": MessageLookupByLibrary.simpleMessage("精度"),
    "Premium": MessageLookupByLibrary.simpleMessage("プレミアム"),
    "Premium_Badge": MessageLookupByLibrary.simpleMessage("プレミアム"),
    "Premium_Benefit_Export": MessageLookupByLibrary.simpleMessage(
      "PDF レポート、CSV 書き出し、結果画像",
    ),
    "Premium_Benefit_History": MessageLookupByLibrary.simpleMessage("すべての計算履歴"),
    "Premium_Benefit_Projects": MessageLookupByLibrary.simpleMessage(
      "保存プロジェクトとプロジェクト全体のレポート",
    ),
    "Premium_Benefit_Sweep": MessageLookupByLibrary.simpleMessage(
      "パラメータスイープの What-if グラフ",
    ),
    "Premium_Benefit_Tools": m7,
    "Premium_Benefit_Universal": MessageLookupByLibrary.simpleMessage(
      "iPhone・iPad でも追加料金なしで利用可能",
    ),
    "Premium_Description": MessageLookupByLibrary.simpleMessage(
      "一度の購入で永続的に解除されます。この Mac でも、iPhone や iPad でも使えます。",
    ),
    "Premium_Free_Tools_Note": m8,
    "Premium_History_Limited": m9,
    "Premium_Locked_Export": MessageLookupByLibrary.simpleMessage(
      "PDF・CSV・画像の書き出しはプレミアムの機能です。",
    ),
    "Premium_Locked_History": MessageLookupByLibrary.simpleMessage(
      "プレミアムでは計算履歴をすべて表示できます。",
    ),
    "Premium_Locked_Projects": MessageLookupByLibrary.simpleMessage(
      "保存プロジェクトはプレミアムの機能です。",
    ),
    "Premium_Locked_Sweep": MessageLookupByLibrary.simpleMessage(
      "What-if グラフはプレミアムの機能です。",
    ),
    "Premium_Locked_Tool": m10,
    "Premium_Not_Found": MessageLookupByLibrary.simpleMessage(
      "プレミアムはまだ App Store で提供されていません。",
    ),
    "Premium_Purchase_Success": MessageLookupByLibrary.simpleMessage(
      "プレミアムを解除しました。すべてのツールとエクスポートが利用できます。",
    ),
    "Premium_Restore_Not_Found": MessageLookupByLibrary.simpleMessage(
      "以前の購入は見つかりませんでした。",
    ),
    "Premium_Restore_Success": MessageLookupByLibrary.simpleMessage(
      "プレミアムの購入を復元しました。",
    ),
    "Premium_Unlocked": MessageLookupByLibrary.simpleMessage("プレミアム解除済み"),
    "Premium_Unlocked_Description": MessageLookupByLibrary.simpleMessage(
      "ME Toolkit をご支援いただきありがとうございます。すべてのツールとエクスポートをご利用いただけます。",
    ),
    "Press_Shrink_Fit_Interference": MessageLookupByLibrary.simpleMessage(
      "圧入・焼きばめのしめしろ",
    ),
    "Pressure_Drop": MessageLookupByLibrary.simpleMessage("圧力損失 Δp"),
    "Pressure_Rise": MessageLookupByLibrary.simpleMessage("圧力上昇 Δp"),
    "Preview_Value": m11,
    "Principal_stresses_and_plane": MessageLookupByLibrary.simpleMessage(
      "主応力と主応力面",
    ),
    "Privacy": MessageLookupByLibrary.simpleMessage("プライバシー"),
    "Privacy_Choices": MessageLookupByLibrary.simpleMessage("プライバシー設定"),
    "Privacy_Choices_Description": MessageLookupByLibrary.simpleMessage(
      "広告に関する同意設定を確認・変更します。",
    ),
    "Privacy_Choices_Unavailable": MessageLookupByLibrary.simpleMessage(
      "プライバシー設定は現在ご利用いただけません。後でもう一度お試しください。",
    ),
    "Privacy_Policy": MessageLookupByLibrary.simpleMessage("プライバシーポリシー"),
    "Product_Not_Found": MessageLookupByLibrary.simpleMessage(
      "「広告を削除」はまだApp Storeでご利用いただけません。",
    ),
    "Project_Calculations": m12,
    "Project_Entry_No_Result": MessageLookupByLibrary.simpleMessage("入力のみ"),
    "Project_Name": MessageLookupByLibrary.simpleMessage("プロジェクト名"),
    "Project_Name_Hint": MessageLookupByLibrary.simpleMessage(
      "例：バルブスプリング — rev C",
    ),
    "Project_Name_Required": MessageLookupByLibrary.simpleMessage(
      "名前を入力してください",
    ),
    "Project_Report_Empty": MessageLookupByLibrary.simpleMessage(
      "このプロジェクトにはまだ保存された結果がありません。計算を開き、プロジェクトに保存してください。",
    ),
    "Project_Saved": m13,
    "Project_Updated": m14,
    "Proof_Strength_Sp": MessageLookupByLibrary.simpleMessage("保証応力 Sp"),
    "Pump_Fan_Power": MessageLookupByLibrary.simpleMessage("ポンプ・ファン動力"),
    "Pump_Head": MessageLookupByLibrary.simpleMessage("全揚程 H"),
    "Purchase_Cancelled": MessageLookupByLibrary.simpleMessage(
      "購入がキャンセルされました。変更はありません。",
    ),
    "Purchase_Failed": MessageLookupByLibrary.simpleMessage(
      "購入を完了できませんでした。もう一度お試しください。",
    ),
    "Purchase_Pending": MessageLookupByLibrary.simpleMessage("購入の承認待ちです。"),
    "Purchase_Success": MessageLookupByLibrary.simpleMessage("広告が完全に削除されました。"),
    "Purchase_Unavailable": MessageLookupByLibrary.simpleMessage(
      "現在購入はご利用いただけません。",
    ),
    "Purchasing": MessageLookupByLibrary.simpleMessage("購入処理中…"),
    "Radius_Gyration_rx": MessageLookupByLibrary.simpleMessage("断面二次半径 rx"),
    "Radius_Gyration_ry": MessageLookupByLibrary.simpleMessage("断面二次半径 ry"),
    "RatethisApp": MessageLookupByLibrary.simpleMessage("このアプリを評価"),
    "Reaction_At_X": m15,
    "Recommended_by_Major": MessageLookupByLibrary.simpleMessage("専攻別のおすすめ"),
    "Relative_Roughness": MessageLookupByLibrary.simpleMessage("相対粗さ ε/D"),
    "Relaxing_Up": MessageLookupByLibrary.simpleMessage("Relaxing Up"),
    "Remove_Ads": MessageLookupByLibrary.simpleMessage("広告を削除"),
    "Remove_Ads_Description": MessageLookupByLibrary.simpleMessage(
      "このアプリから広告を完全に削除します。",
    ),
    "Remove_Dimension": MessageLookupByLibrary.simpleMessage("削除"),
    "Remove_From_Project": MessageLookupByLibrary.simpleMessage("プロジェクトから削除"),
    "Remove_Layer": MessageLookupByLibrary.simpleMessage("層を削除"),
    "Remove_Load": MessageLookupByLibrary.simpleMessage("荷重を削除"),
    "Remove_Tool_from_Favorites": m16,
    "Remove_from_Favorites": MessageLookupByLibrary.simpleMessage("お気に入りから削除"),
    "Removed_from_Favorites": MessageLookupByLibrary.simpleMessage(
      "お気に入りから削除しました",
    ),
    "Rename_Project": MessageLookupByLibrary.simpleMessage("プロジェクト名を変更"),
    "Required_Area_A": MessageLookupByLibrary.simpleMessage("必要伝熱面積 A"),
    "Required_Diameter_D": MessageLookupByLibrary.simpleMessage("必要直径、d"),
    "Restore_Not_Found": MessageLookupByLibrary.simpleMessage(
      "以前の「広告を削除」の購入が見つかりませんでした。",
    ),
    "Restore_Purchases": MessageLookupByLibrary.simpleMessage("購入を復元"),
    "Restore_Success": MessageLookupByLibrary.simpleMessage(
      "「広告を削除」の購入が復元されました。",
    ),
    "Restoring": MessageLookupByLibrary.simpleMessage("復元中…"),
    "Result": MessageLookupByLibrary.simpleMessage("結果"),
    "Result_Copied": MessageLookupByLibrary.simpleMessage("結果をコピーしました"),
    "Result_Precision": MessageLookupByLibrary.simpleMessage("結果の精度"),
    "Result_Strain": MessageLookupByLibrary.simpleMessage("結果のひずみ"),
    "Result_Stress": MessageLookupByLibrary.simpleMessage("結果の応力"),
    "Resultant_of_Forces_2D": MessageLookupByLibrary.simpleMessage("力の合力（2D）"),
    "Reynolds_Number": MessageLookupByLibrary.simpleMessage("レイノルズ数と流れの状態"),
    "Reynolds_Number_Re": MessageLookupByLibrary.simpleMessage("レイノルズ数 Re"),
    "Right_Reaction_RB": MessageLookupByLibrary.simpleMessage("右反力、RB"),
    "Right_Support_Position": MessageLookupByLibrary.simpleMessage("右支点の位置"),
    "Roller_Bearing": MessageLookupByLibrary.simpleMessage("ころ軸受（p = 10/3）"),
    "Roller_Horizontal": MessageLookupByLibrary.simpleMessage("ローラー支点（水平反力）"),
    "Roller_Vertical": MessageLookupByLibrary.simpleMessage("ローラー支点（垂直反力）"),
    "Rotor_Alone_Frequency": MessageLookupByLibrary.simpleMessage(
      "ロータ単独（軸質量なし）",
    ),
    "Rotor_Inertia_J1": MessageLookupByLibrary.simpleMessage("ロータ慣性モーメント, J1"),
    "Rotor_Inertia_J2": MessageLookupByLibrary.simpleMessage(
      "第2ロータの慣性モーメント, J2",
    ),
    "Rotor_Mass_M": MessageLookupByLibrary.simpleMessage("ロータ質量, m"),
    "Rotor_Position_A": MessageLookupByLibrary.simpleMessage("左端からのロータ位置, a"),
    "Rule_of_mixtures": MessageLookupByLibrary.simpleMessage("混合則"),
    "Save": MessageLookupByLibrary.simpleMessage("保存"),
    "Save_To_Project": MessageLookupByLibrary.simpleMessage("プロジェクトに保存"),
    "Save_as_Project": MessageLookupByLibrary.simpleMessage("プロジェクトとして保存"),
    "Saved_Projects": MessageLookupByLibrary.simpleMessage("保存したプロジェクト"),
    "Screw_Efficiency": MessageLookupByLibrary.simpleMessage("効率"),
    "Screw_Pitch_P": MessageLookupByLibrary.simpleMessage("ピッチ p"),
    "Search": MessageLookupByLibrary.simpleMessage("検索"),
    "Search_Bolt_Size_Grade": MessageLookupByLibrary.simpleMessage(
      "サイズまたは強度区分を検索",
    ),
    "Search_Fluids": MessageLookupByLibrary.simpleMessage("流体を検索"),
    "Search_Materials": MessageLookupByLibrary.simpleMessage("材料を検索"),
    "Search_Pipe_Size": MessageLookupByLibrary.simpleMessage(
      "NPS・DN・スケジュールを検索",
    ),
    "Search_Section": MessageLookupByLibrary.simpleMessage("呼称で検索（例：W12X40）"),
    "Search_Size_Or_Fit": MessageLookupByLibrary.simpleMessage("直径またははめあいを検索"),
    "Search_Thread_Size": MessageLookupByLibrary.simpleMessage("ねじサイズを検索"),
    "Search_Tools": MessageLookupByLibrary.simpleMessage("ツールを検索"),
    "Second_Moment_I": MessageLookupByLibrary.simpleMessage("断面二次モーメント、I"),
    "Second_Moment_Ix": MessageLookupByLibrary.simpleMessage("断面二次モーメント、Ix"),
    "Second_Moment_Iy": MessageLookupByLibrary.simpleMessage("断面二次モーメント、Iy"),
    "Section_Depth_d": MessageLookupByLibrary.simpleMessage("せい d"),
    "Section_Designation": MessageLookupByLibrary.simpleMessage("呼称"),
    "Section_Dimensions": MessageLookupByLibrary.simpleMessage("寸法"),
    "Section_Fill_Note": MessageLookupByLibrary.simpleMessage(
      "形鋼を選ぶと下の寸法欄が埋まります。その寸法から計算した断面性能はフィレットを考慮しないため、公称値より数パーセント小さくなります。",
    ),
    "Section_Flange_tf": MessageLookupByLibrary.simpleMessage("フランジ厚 tf"),
    "Section_Modulus_Zx": MessageLookupByLibrary.simpleMessage("断面係数、Zx"),
    "Section_Modulus_Zy": MessageLookupByLibrary.simpleMessage("断面係数、Zy"),
    "Section_Web_tw": MessageLookupByLibrary.simpleMessage("ウェブ厚 tw"),
    "Section_Width_b": MessageLookupByLibrary.simpleMessage("幅 b"),
    "Sections_Footnote": MessageLookupByLibrary.simpleMessage(
      "掲載形鋼の公称値です。断面係数と断面二次半径は掲載の A と I から算出しています。詳細設計の前に最新のメーカー資料または規格表を確認してください。",
    ),
    "See_Premium": MessageLookupByLibrary.simpleMessage("プレミアムを見る"),
    "Self_Locking_Thread": MessageLookupByLibrary.simpleMessage("ねじ面で自立する"),
    "Settings": MessageLookupByLibrary.simpleMessage("設定"),
    "Shaft_Alone_Frequency": MessageLookupByLibrary.simpleMessage("軸質量のみ"),
    "Shaft_And_Rotor": MessageLookupByLibrary.simpleMessage("軸とロータ"),
    "Shaft_Between_Bearings": MessageLookupByLibrary.simpleMessage("両端軸受支持"),
    "Shaft_Both_Ends_Fixed": MessageLookupByLibrary.simpleMessage("両端固定"),
    "Shaft_Critical_Speed": MessageLookupByLibrary.simpleMessage("軸の危険速度"),
    "Shaft_Diameter_D": MessageLookupByLibrary.simpleMessage("軸径, d"),
    "Shaft_Fatigue_Design": MessageLookupByLibrary.simpleMessage(
      "軸の疲労設計（DE-グッドマン法）",
    ),
    "Shaft_Length_L": MessageLookupByLibrary.simpleMessage("軸長さ, L"),
    "Shaft_Mass": MessageLookupByLibrary.simpleMessage("軸質量"),
    "Shaft_Overhung": MessageLookupByLibrary.simpleMessage("オーバーハング"),
    "Shaft_Power": MessageLookupByLibrary.simpleMessage("軸動力"),
    "Shaft_Stiffness_K": MessageLookupByLibrary.simpleMessage("ロータ位置の軸剛性, k"),
    "Shaft_Surface_Stress": MessageLookupByLibrary.simpleMessage("軸表面応力、σs"),
    "Shaft_power_and_torque": MessageLookupByLibrary.simpleMessage("軸の動力とトルク"),
    "Shaft_um": MessageLookupByLibrary.simpleMessage("軸 (µm)"),
    "Shape": MessageLookupByLibrary.simpleMessage("形状"),
    "Shape_Type": MessageLookupByLibrary.simpleMessage("形状タイプ"),
    "Share_Format_CSV": MessageLookupByLibrary.simpleMessage("CSV"),
    "Share_Format_CSV_Description": MessageLookupByLibrary.simpleMessage(
      "数値と単位の表計算ファイル",
    ),
    "Share_Format_Image": MessageLookupByLibrary.simpleMessage("画像"),
    "Share_Format_Image_Description": MessageLookupByLibrary.simpleMessage(
      "この結果画面の画像",
    ),
    "Share_Format_PDF": MessageLookupByLibrary.simpleMessage("PDF"),
    "Share_Format_PDF_Description": MessageLookupByLibrary.simpleMessage(
      "表と計算式を含むレポート",
    ),
    "Share_Format_Text": MessageLookupByLibrary.simpleMessage("テキスト"),
    "Share_Format_Text_Description": MessageLookupByLibrary.simpleMessage(
      "どこにでも貼り付けられるプレーンテキスト",
    ),
    "Share_Results": MessageLookupByLibrary.simpleMessage("結果を共有"),
    "SharethisApp": MessageLookupByLibrary.simpleMessage("このアプリを共有"),
    "Shear_Force_Diagram": MessageLookupByLibrary.simpleMessage("せん断力図"),
    "Shear_Modulus_G": MessageLookupByLibrary.simpleMessage("横弾性係数、G"),
    "Shear_Stress_Tau": MessageLookupByLibrary.simpleMessage("せん断応力、τ"),
    "Shows": MessageLookupByLibrary.simpleMessage("Shows"),
    "Simple_Calculator": MessageLookupByLibrary.simpleMessage(
      "Simple Calculator",
    ),
    "Simple_English_Dictionary": MessageLookupByLibrary.simpleMessage(
      "Simple English Dictionary",
    ),
    "Simply_Supported_Beam": MessageLookupByLibrary.simpleMessage("単純支持梁"),
    "Simply_Supported_Beam_Note": MessageLookupByLibrary.simpleMessage(
      "単純支持梁 — A点（左）はピン支点、B点（右）はローラー支点",
    ),
    "Single_Shear": MessageLookupByLibrary.simpleMessage("一面せん断"),
    "Slope": MessageLookupByLibrary.simpleMessage("たわみ角"),
    "Small_Pulley_Diameter_D1": MessageLookupByLibrary.simpleMessage(
      "小プーリー径、d1",
    ),
    "Solid_Height": MessageLookupByLibrary.simpleMessage("密着高さ"),
    "Span_L": MessageLookupByLibrary.simpleMessage("スパン、L"),
    "Span_L_Short": MessageLookupByLibrary.simpleMessage("スパン L"),
    "Speed_N": MessageLookupByLibrary.simpleMessage("回転速度、n"),
    "Speed_Ratio": MessageLookupByLibrary.simpleMessage("速度比"),
    "Spring_Index_C": MessageLookupByLibrary.simpleMessage("ばね指数、C"),
    "Spring_Rate_K": MessageLookupByLibrary.simpleMessage("ばね定数、k"),
    "Spur_Gear_Geometry": MessageLookupByLibrary.simpleMessage("平歯車の幾何形状"),
    "Stackup_Adds": MessageLookupByLibrary.simpleMessage("加える"),
    "Stackup_Clearance": MessageLookupByLibrary.simpleMessage("常にすきまあり"),
    "Stackup_Contributions": MessageLookupByLibrary.simpleMessage("ばらつきの寄与"),
    "Stackup_Dimension_N": m17,
    "Stackup_Dimensions": MessageLookupByLibrary.simpleMessage("寸法の連なり"),
    "Stackup_Dominant": MessageLookupByLibrary.simpleMessage("最大の寄与"),
    "Stackup_Footnote": MessageLookupByLibrary.simpleMessage(
      "ワーストケース法は単純な足し引きで、これが成立すれば組立は必ず可能です。RSS は各寸法が独立にばらつき、公差域の中心にあり、およそ正規分布であることを前提とします。5 個程度の小さな数では意味をもたず、工程が偏るときや供給者が公差域の端で作るときはばらつきを小さく見積もります。設計はワーストケースで、公差の配分は RSS の示すところで行ってください。",
    ),
    "Stackup_Interference": MessageLookupByLibrary.simpleMessage("しめしろの可能性"),
    "Stackup_Line_To_Line": MessageLookupByLibrary.simpleMessage("すきまゼロ"),
    "Stackup_Maximum": MessageLookupByLibrary.simpleMessage("最大"),
    "Stackup_Mean": MessageLookupByLibrary.simpleMessage("平均"),
    "Stackup_Minimum": MessageLookupByLibrary.simpleMessage("最小"),
    "Stackup_Outcome": MessageLookupByLibrary.simpleMessage("ワーストケースの結果"),
    "Stackup_RSS": MessageLookupByLibrary.simpleMessage("統計(RSS)"),
    "Stackup_RSS_Saving": MessageLookupByLibrary.simpleMessage("RSS による幅の縮小"),
    "Stackup_Spread": MessageLookupByLibrary.simpleMessage("全体のばらつき"),
    "Stackup_Subtracts": MessageLookupByLibrary.simpleMessage("引く"),
    "Stackup_Worst_Case": MessageLookupByLibrary.simpleMessage("ワーストケース"),
    "Standard_Sections": MessageLookupByLibrary.simpleMessage("標準形鋼"),
    "Static_Deflection_Delta": MessageLookupByLibrary.simpleMessage(
      "静たわみ, δst",
    ),
    "Stiffness_Matrix_C": MessageLookupByLibrary.simpleMessage("剛性マトリクス C"),
    "Stiffness_Matrix_Q": MessageLookupByLibrary.simpleMessage("剛性マトリクス Q"),
    "Strain": MessageLookupByLibrary.simpleMessage("ひずみ"),
    "Stress": MessageLookupByLibrary.simpleMessage("応力"),
    "Stress_Area_As": MessageLookupByLibrary.simpleMessage("有効断面積"),
    "Stress_Concentration_Defaults": MessageLookupByLibrary.simpleMessage(
      "応力集中係数（既定値：成形キー溝）と目標安全率",
    ),
    "Stress_Results": MessageLookupByLibrary.simpleMessage("応力の結果"),
    "Stresses_in_a_thin_walled_cylindrical_pressure_vessel":
        MessageLookupByLibrary.simpleMessage("薄肉円筒圧力容器の応力"),
    "Stresses_in_the_wall_of_a_spherical_shell":
        MessageLookupByLibrary.simpleMessage("球殻壁面の応力"),
    "Stressstrain_of_linear_elastic_material":
        MessageLookupByLibrary.simpleMessage("線形弾性材料の応力/ひずみ"),
    "Strong_Axis": MessageLookupByLibrary.simpleMessage("強軸 (x-x)"),
    "Subtract": MessageLookupByLibrary.simpleMessage("差し引く"),
    "Sudoku_Lover": MessageLookupByLibrary.simpleMessage("Sudoku Lover"),
    "Support": MessageLookupByLibrary.simpleMessage("支点"),
    "Support_Arrangement": MessageLookupByLibrary.simpleMessage("支持条件"),
    "Support_Cantilever_Left": MessageLookupByLibrary.simpleMessage(
      "片持ち（左端固定）",
    ),
    "Support_Cantilever_Right": MessageLookupByLibrary.simpleMessage(
      "片持ち（右端固定）",
    ),
    "Support_Fixed_Fixed": MessageLookupByLibrary.simpleMessage("両端固定"),
    "Support_Overhang": MessageLookupByLibrary.simpleMessage("張り出しはり"),
    "Support_Propped_Cantilever": MessageLookupByLibrary.simpleMessage(
      "一端固定・他端支持",
    ),
    "Support_Reactions": MessageLookupByLibrary.simpleMessage("支点反力"),
    "Support_Simply_Supported": MessageLookupByLibrary.simpleMessage("単純支持"),
    "Swap": MessageLookupByLibrary.simpleMessage("入れ替え"),
    "SwiftComp": MessageLookupByLibrary.simpleMessage(
      "SwiftComp:Composites Material",
    ),
    "System_Default": MessageLookupByLibrary.simpleMessage("システムの既定値"),
    "Tangential_Load_Wt": MessageLookupByLibrary.simpleMessage("接線荷重、Wt"),
    "Tap_Drill": MessageLookupByLibrary.simpleMessage("下穴径"),
    "Target_Factor_of_Safety_N": MessageLookupByLibrary.simpleMessage(
      "目標安全率、n",
    ),
    "Target_Preload_F": MessageLookupByLibrary.simpleMessage("目標初期張力、F"),
    "Target_Safety_Factor_N": MessageLookupByLibrary.simpleMessage("目標安全率、n"),
    "The_Maximum_Shear_Stress": MessageLookupByLibrary.simpleMessage("最大せん断応力"),
    "Theme_Dark": MessageLookupByLibrary.simpleMessage("ダーク"),
    "Theme_Dark_Description": MessageLookupByLibrary.simpleMessage(
      "常にダークテーマを使用します",
    ),
    "Theme_Light": MessageLookupByLibrary.simpleMessage("ライト"),
    "Theme_Light_Description": MessageLookupByLibrary.simpleMessage(
      "常にライトテーマを使用します",
    ),
    "Theme_System": MessageLookupByLibrary.simpleMessage("システム設定に従う"),
    "Theme_System_Description": MessageLookupByLibrary.simpleMessage(
      "デバイスの外観設定に従います",
    ),
    "Theory_of_Elasticity": MessageLookupByLibrary.simpleMessage("弾性理論"),
    "Thermal": MessageLookupByLibrary.simpleMessage("熱"),
    "Thermal_Material_Presets": MessageLookupByLibrary.simpleMessage("熱物性材料"),
    "Thermal_Results": MessageLookupByLibrary.simpleMessage("熱解析の結果"),
    "Thermal_deformation_and_stress": MessageLookupByLibrary.simpleMessage(
      "熱変形と熱応力",
    ),
    "Thickness_t": MessageLookupByLibrary.simpleMessage("厚さ t"),
    "Thread": MessageLookupByLibrary.simpleMessage("ねじ"),
    "Thread_Form": MessageLookupByLibrary.simpleMessage("ねじ山の形"),
    "Thread_Form_ACME": MessageLookupByLibrary.simpleMessage("ACME 29°"),
    "Thread_Form_Square": MessageLookupByLibrary.simpleMessage("角ねじ"),
    "Thread_Form_Trapezoidal": MessageLookupByLibrary.simpleMessage("台形 30°"),
    "Thread_Friction_Mu": MessageLookupByLibrary.simpleMessage("ねじ面の摩擦係数 μ"),
    "Thread_Starts": MessageLookupByLibrary.simpleMessage("条数"),
    "Thread_Torque_Lower": MessageLookupByLibrary.simpleMessage("ねじ面トルク（下降）"),
    "Thread_Torque_Raise": MessageLookupByLibrary.simpleMessage("ねじ面トルク（上昇）"),
    "Tightening_Torque_T": MessageLookupByLibrary.simpleMessage("締付けトルク、T"),
    "Tip_Temperature": MessageLookupByLibrary.simpleMessage("先端温度"),
    "Tolerance_Stackup": MessageLookupByLibrary.simpleMessage("公差の積み上げ"),
    "Torque_T": MessageLookupByLibrary.simpleMessage("締付トルク T"),
    "Torque_To_Lower": MessageLookupByLibrary.simpleMessage("下降トルク"),
    "Torque_To_Raise": MessageLookupByLibrary.simpleMessage("上昇トルク"),
    "Torsion_formula_of_bar": MessageLookupByLibrary.simpleMessage("棒のねじり公式"),
    "Torsional_Footnote": MessageLookupByLibrary.simpleMessage(
      "軸自身の慣性は無視しています。ロータと同程度の場合は、多質点系（ホルツァー法）で解析してください。",
    ),
    "Torsional_Natural_Frequency": MessageLookupByLibrary.simpleMessage(
      "ねじり固有振動数",
    ),
    "Torsional_Single_Rotor": MessageLookupByLibrary.simpleMessage(
      "ロータ1個、他端固定",
    ),
    "Torsional_Stiffness_Kt": MessageLookupByLibrary.simpleMessage("ねじり剛性, kt"),
    "Torsional_Two_Rotor": MessageLookupByLibrary.simpleMessage("ロータ2個、自由軸"),
    "Total_Head_Loss": MessageLookupByLibrary.simpleMessage("全損失水頭"),
    "Total_Resistance_R": MessageLookupByLibrary.simpleMessage("総熱抵抗 R"),
    "Transverse_shear_stress_in_beam": MessageLookupByLibrary.simpleMessage(
      "梁の横せん断応力",
    ),
    "Transversely_isotropic_material": MessageLookupByLibrary.simpleMessage(
      "横等方性材料",
    ),
    "Truss_Analysis_Method_of_Joints": MessageLookupByLibrary.simpleMessage(
      "トラス解析（節点法）",
    ),
    "Truss_Geometry": MessageLookupByLibrary.simpleMessage("トラス形状"),
    "Truss_Statics": MessageLookupByLibrary.simpleMessage("トラス / 静力学"),
    "UDL": MessageLookupByLibrary.simpleMessage("等分布荷重"),
    "Ultimate_Strength": MessageLookupByLibrary.simpleMessage("引張強さ"),
    "Ultimate_Strength_Sut": MessageLookupByLibrary.simpleMessage("引張強さ、Sut"),
    "Unified_Coarse": MessageLookupByLibrary.simpleMessage("ユニファイ並目 (UNC)"),
    "Unified_Fine": MessageLookupByLibrary.simpleMessage("ユニファイ細目 (UNF)"),
    "Uniform_Distributed_Load_Full_Span": MessageLookupByLibrary.simpleMessage(
      "全スパン等分布荷重",
    ),
    "Unit_Converter": MessageLookupByLibrary.simpleMessage("単位換算"),
    "Unit_System": MessageLookupByLibrary.simpleMessage("単位系"),
    "Unlock_Premium": MessageLookupByLibrary.simpleMessage("プレミアムを解除"),
    "Utilities": MessageLookupByLibrary.simpleMessage("ツール"),
    "Velocity_Head": MessageLookupByLibrary.simpleMessage("速度水頭 V²/2g"),
    "Vibration_Modes": MessageLookupByLibrary.simpleMessage("固有振動数"),
    "W_Intensity": MessageLookupByLibrary.simpleMessage("w（荷重強度）"),
    "Wahl_Factor_Kw": MessageLookupByLibrary.simpleMessage("ワール係数、Kw"),
    "Wall_Area_A": MessageLookupByLibrary.simpleMessage("壁面積 A"),
    "Wall_Interface": MessageLookupByLibrary.simpleMessage("界面"),
    "Wall_Layers": MessageLookupByLibrary.simpleMessage("壁の層構成"),
    "Wall_Roughness": MessageLookupByLibrary.simpleMessage("管壁粗さ ε"),
    "Wall_Surface": MessageLookupByLibrary.simpleMessage("壁面"),
    "Wall_Temperatures": MessageLookupByLibrary.simpleMessage("壁内の温度分布"),
    "Wall_Thickness": MessageLookupByLibrary.simpleMessage("肉厚"),
    "Water_Tracker": MessageLookupByLibrary.simpleMessage("Water Tracker"),
    "Weak_Axis": MessageLookupByLibrary.simpleMessage("弱軸 (y-y)"),
    "Web_Thickness": MessageLookupByLibrary.simpleMessage("ウェブ厚"),
    "What_If": m18,
    "Wire_Diameter_D": MessageLookupByLibrary.simpleMessage("線径、d"),
    "World_Weather_Live": MessageLookupByLibrary.simpleMessage(
      "World Weather Live",
    ),
    "Wrap_Angle_Large_Pulley": MessageLookupByLibrary.simpleMessage(
      "巻き付け角、大プーリー",
    ),
    "Wrap_Angle_Small_Pulley": MessageLookupByLibrary.simpleMessage(
      "巻き付け角、小プーリー",
    ),
    "Yes_Habit": MessageLookupByLibrary.simpleMessage("Yes Habit"),
    "Yield_Strength": MessageLookupByLibrary.simpleMessage("降伏強さ"),
  };
}
