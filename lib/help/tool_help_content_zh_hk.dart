import 'package:mechanical_engineering_toolkit/help/tool_help.dart';

/// Traditional Chinese tool explanations.
///
/// Equations, symbol glyphs and units are not translated: they are the same
/// notation on a drawing in every language. References stay in English
/// because they are citations — a reader looking the book up needs the title
/// it was published under.
const Map<int, ToolHelp> toolHelpZhHk = {
  100: ToolHelp(
    summary: '等截面直桿在軸向載荷下的單向應力與應變。正應力是載荷除以承載面積，'
        '在材料保持彈性時應變由胡克定律得出。這是其他所有應力計算的起點：'
        '拉桿、吊桿、純受拉的螺栓都用它。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A}',
        plain: 'σ = P / A',
        caption: '正應力',
      ),
      HelpFormula(
        tex: r'\varepsilon = \frac{\sigma}{E} = \frac{\delta}{L}',
        plain: 'ε = σ / E = δ / L',
        caption: '彈性範圍內的應變',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '正應力', 'MPa'),
      HelpSymbol('P', '軸向力，受拉為正', 'N'),
      HelpSymbol('A', '橫截面積', 'mm²'),
      HelpSymbol('E', '彈性模量', 'MPa'),
      HelpSymbol('ε', '正應變'),
    ],
    notes: [
      '假定應力在截面上均匀分布。這在遠離加載點、孔和截面突變處成立，'
          '即聖維南原理。靠近這些位置會出現本式看不到的應力集中。',
      '僅適用於彈性範圍。σ 超過比例極限後 ε = σ/E 不再成立，桿件會產生殘餘變形。',
      '細長桿受壓時，遠在達到該應力之前就會屈曲。請同時使用壓桿屈曲工具校核。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 1–3',
      'Gere & Goodno, Mechanics of Materials, ch. 1',
    ],
    diagram: 'images/icon_bar_force.png',
  ),
  101: ToolHelp(
    summary: '等截面直桿的軸向伸長及其對應的剛度。桿件相當於一個剛度為 AE/L 的線性彈簧，'
        '因此該關係是螺栓連接、拉桿体系以及任何用剛度疊加求解的結構的基本單元。',
    formulas: [
      HelpFormula(
        tex: r'\delta = \frac{PL}{AE}',
        plain: 'δ = P·L / (A·E)',
        caption: '伸長量',
      ),
      HelpFormula(
        tex: r'k = \frac{AE}{L}',
        plain: 'k = A·E / L',
        caption: '軸向剛度',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '伸長量，受拉為正', 'mm'),
      HelpSymbol('P', '軸向力', 'N'),
      HelpSymbol('L', '原始長度', 'mm'),
      HelpSymbol('A', '橫截面積', 'mm²'),
      HelpSymbol('E', '彈性模量', 'MPa'),
      HelpSymbol('k', '軸向剛度', 'N/mm'),
    ],
    notes: [
      '適用於沿長度方向 P、A、E 均為常量的等截面桿。階梯桿、變截面桿或計入自重時，'
          '應分段計算再把伸長量相加。',
      '小變形線彈性理論。δ 按原始長度計算，而非變形後的長度。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/bar_force_displacement.png',
  ),
  103: ToolHelp(
    summary: '圓截面軸在純扭轉下的剪應力。應力沿半徑從軸心的零線性增大到表面的最大值，'
        '因此在外徑相同的條件下，空心軸几乎能承受與實心軸相當的扭矩，而重量却輕得多。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{T\rho}{J}',
        plain: 'τ = T·ρ / J',
        caption: '半徑 ρ 處的剪應力',
      ),
      HelpFormula(
        tex: r'J_{\text{solid}} = \frac{\pi d^4}{32}, \quad '
            r'J_{\text{hollow}} = \frac{\pi (d_o^4 - d_i^4)}{32}',
        plain: 'J = π·d⁴/32（實心），J = π·(do⁴ − di⁴)/32（空心）',
        caption: '極慣性矩',
      ),
    ],
    symbols: [
      HelpSymbol('τ', '剪應力', 'MPa'),
      HelpSymbol('T', '扭矩', 'N·mm'),
      HelpSymbol('ρ', '所求點的半徑', 'mm'),
      HelpSymbol('J', '極慣性矩', 'mm⁴'),
    ],
    notes: [
      '僅適用於圓截面。非圓截面軸受扭時會發生翹曲，本式完全不適用，'
          '方形和矩形截面需要各自的扭轉常數。',
      '線彈性、純扭轉。彎扭組合應先用組合受力工具，再用強度理論校核。',
      '當其他量以 mm 和 MPa 為單位時，T 應取 N·mm。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Gere & Goodno, Mechanics of Materials, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  114: ToolHelp(
    summary: '軸在扭矩作用下一端相對另一端轉過的角度。扭轉角決定傳動軸的手感是否"發軟"、'
        '扭桿能否達到設計剛度，以及在超靜定系統中扭矩如何在並聯路徑間分配。',
    formulas: [
      HelpFormula(
        tex: r'\phi = \frac{TL}{GJ}',
        plain: 'φ = T·L / (G·J)',
        caption: '扭轉角，單位為弧度',
      ),
      HelpFormula(
        tex: r'k_t = \frac{GJ}{L}',
        plain: 'kt = G·J / L',
        caption: '扭轉剛度',
      ),
    ],
    symbols: [
      HelpSymbol('φ', '扭轉角', 'rad'),
      HelpSymbol('T', '扭矩', 'N·mm'),
      HelpSymbol('L', '產生扭轉的長度', 'mm'),
      HelpSymbol('G', '剪切模量', 'MPa'),
      HelpSymbol('J', '極慣性矩', 'mm⁴'),
    ],
    notes: [
      '適用於 T、G、J 沿長度不變的等截面圓軸。任一量發生變化時，應分段計算再把扭轉角相加。',
      'G 與 E 並不獨立：各向同性材料滿足 G = E / [2(1 + ν)]，鋼約為 0.385·E。',
      '結果以弧度表示，乘以 180/π 可換算為度。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  115: ToolHelp(
    summary: '由功率和轉速求旋轉軸傳遞的扭矩，或由已知扭矩求功率。任何軸的設計都從這裡開始：'
        '電机銘牌給出功率和轉速，而軸必須按由此得到的扭矩來設計。',
    formulas: [
      HelpFormula(
        tex: r'P = T\omega, \quad \omega = \frac{2\pi n}{60}',
        plain: 'P = T·ω，ω = 2π·n / 60',
        caption: '由扭矩和轉速求功率',
      ),
      HelpFormula(
        tex: r'T = \frac{9549\,P_{\text{kW}}}{n}',
        plain: 'T [N·m] = 9549 · P [kW] / n [rpm]',
        caption: '工程常用形式',
      ),
    ],
    symbols: [
      HelpSymbol('P', '傳遞功率', 'W'),
      HelpSymbol('T', '扭矩', 'N·m'),
      HelpSymbol('ω', '角速度', 'rad/s'),
      HelpSymbol('n', '轉速', 'rpm'),
    ],
    notes: [
      '這是穩定轉速下傳遞的扭矩。啟動、制動和卡死工況的扭矩可能高出數倍，'
          '設計軸之前應先乘以工況係數。',
      '功率有進有出：傳動裝置的損失需要單獨用效率去除來考慮。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'Hibbeler, Mechanics of Materials, ch. 5',
    ],
  ),
  109: ToolHelp(
    summary: '薄壁球形壓力容器壁內的薄膜應力。球是承壓效率最高的形狀：'
        '各個方向的應力相同，且只有相同半徑和壁厚的圓筒環向應力的一半。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{pr}{2t}',
        plain: 'σ = p·r / (2·t)',
        caption: '薄膜應力，各方向相同',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '薄膜應力', 'MPa'),
      HelpSymbol('p', '內部表壓', 'MPa'),
      HelpSymbol('r', '內半徑', 'mm'),
      HelpSymbol('t', '壁厚', 'mm'),
    ],
    notes: [
      '薄壁理論，r/t 大於約 10 時有效。低於該值時應力沿壁厚變化，需用厚壁（拉梅）解。',
      '僅為薄膜應力。接管、支座以及與其他形狀的連接處局部應力遠高於此，'
          '壓力容器規範的大量篇幅正是為此。',
      '按 ASME VIII 等規範設計時還需計入焊縫係數和腐蝕裕量，這裡只是純力學。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_spherical_shell_stress.png',
  ),
  110: ToolHelp(
    summary: '薄壁圓筒在內壓下的環向和軸向薄膜應力。環向應力是軸向應力的兩倍，'
        '這正是承壓管道沿長度方向開裂、而不是沿圓周斷開的原因。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_h = \frac{pr}{t}',
        plain: 'σh = p·r / t',
        caption: '環向應力',
      ),
      HelpFormula(
        tex: r'\sigma_l = \frac{pr}{2t}',
        plain: 'σl = p·r / (2·t)',
        caption: '軸向應力',
      ),
    ],
    symbols: [
      HelpSymbol('σh', '環向應力', 'MPa'),
      HelpSymbol('σl', '軸向應力', 'MPa'),
      HelpSymbol('p', '內部表壓', 'MPa'),
      HelpSymbol('r', '內半徑', 'mm'),
      HelpSymbol('t', '壁厚', 'mm'),
    ],
    notes: [
      '薄壁理論，r/t 大於約 10 時有效。',
      '這兩個應力就是壁面上的主應力，第三個主應力約為零。把它們輸入強度理論工具即可得到當量應力。',
      '只有封閉圓筒才存在軸向應力。以其他方式約束的敞口管道，其軸向載荷並不相同。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_cylindrical_pressure_stress.png',
  ),
  107: ToolHelp(
    summary: '把平面應力狀態旋轉到任意一組新坐標軸上。同一個物理應力狀態，'
        '在不同的截面上讀數並不相同；應力轉換正是用來求焊縫、膠接面或纖維方向上的應力，'
        '而這些方向往往與零件的坐標軸並不一致。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{x\prime} = \frac{\sigma_x+\sigma_y}{2} + '
            r'\frac{\sigma_x-\sigma_y}{2}\cos 2\theta + \tau_{xy}\sin 2\theta',
        plain: 'σx\' = (σx+σy)/2 + (σx−σy)/2·cos2θ + τxy·sin2θ',
      ),
      HelpFormula(
        tex: r'\tau_{x\prime y\prime} = -\frac{\sigma_x-\sigma_y}{2}'
            r'\sin 2\theta + \tau_{xy}\cos 2\theta',
        plain: 'τx\'y\' = −(σx−σy)/2·sin2θ + τxy·cos2θ',
      ),
    ],
    symbols: [
      HelpSymbol('σx, σy', '原坐標軸上的正應力', 'MPa'),
      HelpSymbol('τxy', '原坐標軸上的剪應力', 'MPa'),
      HelpSymbol('θ', '轉到新軸的角度，逆時針為正', '°'),
    ],
    notes: [
      '平面應力：第三主應力為零。這對面內受載的薄板是好模型，對厚實体內部則不適用。',
      '符號約定：拉應力為正；剪應力作用在 +x 面上并指向 +y 時為正。'
          '符號弄錯是本工具出錯的最常見原因。',
      '轉換式中角度是加倍出現的，莫爾圓畫的正是這一點——同樣的關係，只是用几何表示。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  108: ToolHelp(
    summary: '一點處最大和最小的正應力，以及它們所在的平面。'
        '大多數強度理論都是用主應力表述的，因此這一步通常位於應力分析和安全係數之間。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{1,2} = \frac{\sigma_x+\sigma_y}{2} \pm '
            r'\sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}',
        plain: 'σ1,2 = (σx+σy)/2 ± √[ ((σx−σy)/2)² + τxy² ]',
        caption: '主應力',
      ),
      HelpFormula(
        tex: r'\tan 2\theta_p = \frac{2\tau_{xy}}{\sigma_x-\sigma_y}',
        plain: 'tan2θp = 2·τxy / (σx − σy)',
        caption: '主平面方位',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{\sigma_1-\sigma_2}{2}',
        plain: 'τmax = (σ1 − σ2) / 2',
        caption: '面內最大剪應力',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '主應力，σ1 ≥ σ2', 'MPa'),
      HelpSymbol('θp', '從 x 軸轉到 σ1 所在面的角度', '°'),
      HelpSymbol('τmax', '面內最大剪應力', 'MPa'),
    ],
    notes: [
      '主平面上没有剪應力，這正是主平面的定義。',
      '平面應力中第三主應力為零，而它仍可能是三者中最小的。'
          '真正的最大剪應力是三個主應力中 (σmax − σmin)/2，'
          '當 σ1 與 σ2 同號時，它大於面內值。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/icon_stress_element.png',
  ),
  118: ToolHelp(
    summary: '莫爾圓是把應力轉換畫成几何圖形。過該點的每一個截面都對應圓上的一個點，'
        '圓心為平均正應力，半徑為面內最大剪應力，因此主應力及其方位一眼即可讀出。',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{\sigma_x+\sigma_y}{2}, \quad '
            r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2+\tau_{xy}^2}',
        plain: 'C = (σx+σy)/2，R = √[ ((σx−σy)/2)² + τxy² ]',
        caption: '圓心與半徑',
      ),
      HelpFormula(
        tex: r'\sigma_{1,2} = C \pm R, \quad \tau_{\max} = R',
        plain: 'σ1,2 = C ± R，τmax = R',
      ),
    ],
    symbols: [
      HelpSymbol('C', '圓心，即平均正應力', 'MPa'),
      HelpSymbol('R', '圓半徑，即面內最大剪應力', 'MPa'),
      HelpSymbol('σx, σy, τxy', '所繪制的應力狀態', 'MPa'),
    ],
    notes: [
      '在圓上轉一整圈，對應單元体實際轉過 180°：圓上的角度是實際角度的兩倍。',
      '僅適用於平面應力。完整的三維應力狀態要畫三個圓，最外面的那個決定最大剪應力。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  116: ToolHelp(
    summary: '把二維應力狀態折算成一個可以與屈服強度比較的當量應力。'
        '第四強度理論（von Mises，形狀改變比能）是韌性金屬的常規選擇；'
        '第三強度理論（Tresca，最大剪應力）略偏保守，若干壓力容器規範至今仍在使用。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}',
        plain: 'σVM = √(σ1² − σ1·σ2 + σ2²)',
        caption: 'von Mises，平面應力',
      ),
      HelpFormula(
        tex: r'\sigma_{Tresca} = |\sigma_1 - \sigma_2|',
        plain: 'σTresca = |σ1 − σ2|',
        caption: 'Tresca 當量應力',
      ),
      HelpFormula(
        tex: r'n = \frac{S_y}{\sigma_{eq}}',
        plain: 'n = Sy / σeq',
        caption: '抗屈服安全係數',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '主應力', 'MPa'),
      HelpSymbol('σVM', 'von Mises 當量應力', 'MPa'),
      HelpSymbol('Sy', '屈服強度', 'MPa'),
      HelpSymbol('n', '安全係數'),
    ],
    notes: [
      '兩種準則都用於預測韌性材料的屈服。脆性材料按最大主應力或莫爾–庫侖準則失效，'
          '把 von Mises 用在鑄鐵上會給出誤導性的結果。',
      'Tresca 更保守，最多約保守 15%：兩者在單向拉伸時一致，在純剪時差別最大。',
      '僅適用於靜載屈服。交變載荷需要使用疲勞準則。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 5',
      'Hibbeler, Mechanics of Materials, ch. 10',
    ],
  ),
  119: ToolHelp(
    summary: '用修正 Goodman 準則計算承受非零平均應力的交變載荷零件的安全係數。'
        '平均拉應力會使疲勞比單看交變分量時更為不利，Goodman 是考慮這一影響的'
        '標準且略偏保守的方法。',
    formulas: [
      HelpFormula(
        tex: r'\frac{\sigma_a}{S_e} + \frac{\sigma_m}{S_{ut}} = \frac{1}{n}',
        plain: 'σa/Se + σm/Sut = 1/n',
        caption: '修正 Goodman 直線',
      ),
      HelpFormula(
        tex: r'\sigma_a = \frac{\sigma_{\max}-\sigma_{\min}}{2}, \quad '
            r'\sigma_m = \frac{\sigma_{\max}+\sigma_{\min}}{2}',
        plain: 'σa = (σmax − σmin)/2，σm = (σmax + σmin)/2',
        caption: '交變分量與平均分量',
      ),
    ],
    symbols: [
      HelpSymbol('σa', '交變應力幅', 'MPa'),
      HelpSymbol('σm', '平均應力', 'MPa'),
      HelpSymbol('Se', '修正後的持久極限', 'MPa'),
      HelpSymbol('Sut', '抗拉強度', 'MPa'),
      HelpSymbol('n', '抗疲勞安全係數'),
    ],
    notes: [
      'Se 留空時取 0.5·Sut，這是鋼的常用初估值。它尚未修正：'
          '實際設計還要乘以表面、尺寸、載荷、溫度和可靠性等 Marin 係數，通常會再降低一半左右。',
      '有色金屬和鋁没有真正的持久極限，其強度隨循環次數持續下降，'
          '因此需要按有限壽命計算而非本式。',
      '平均壓應力的損傷机理不同。把 Goodman 用於負的 σm 會保守到失真，'
          '此時應取 σm = 0。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 6',
      'Norton, Machine Design, ch. 6',
    ],
  ),
  112: ToolHelp(
    summary: '桿件的自由熱膨脹，以及當膨脹被約束時產生的應力。'
        '完全約束的構件所產生的應力只取決於材料和溫差，而與長度和截面積無關，'
        '這正是長管道需要膨脹彎而不是更厚的壁的原因。',
    formulas: [
      HelpFormula(
        tex: r'\delta_T = \alpha \, \Delta T \, L',
        plain: 'δT = α · ΔT · L',
        caption: '自由膨脹量',
      ),
      HelpFormula(
        tex: r'\sigma_T = -E \alpha \, \Delta T',
        plain: 'σT = −E · α · ΔT',
        caption: '完全約束時的應力',
      ),
    ],
    symbols: [
      HelpSymbol('δT', '自由長度變化', 'mm'),
      HelpSymbol('α', '線膨脹係數', '1/°C'),
      HelpSymbol('ΔT', '溫度變化', '°C'),
      HelpSymbol('L', '原始長度', 'mm'),
      HelpSymbol('σT', '熱應力，受熱時為壓應力', 'MPa'),
    ],
    notes: [
      '約束應力與 L 和 A 無關。把構件做粗並不能降低它，只有允許其移動或減小 ΔT 才行。',
      '完全約束是最不利情況。部分約束時應力介於零與該值之間，與被限制的位移比例相關。',
      'α 隨溫度變化；溫度範圍較大時應取區間平均值，而不是室溫值。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
  ),
  111: ToolHelp(
    summary: '細長壓桿喪失穩定并側向彎曲時的軸向載荷。屈曲是剛度失效而非強度失效：'
        '臨界載荷取決於 E 和 I，几乎與材料強度無關。'
        '長壓桿可能在遠低於屈服載荷的水平上就屈曲。',
    formulas: [
      HelpFormula(
        tex: r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}',
        plain: 'Pcr = π²·E·I / (K·L)²',
        caption: '歐拉臨界載荷',
      ),
      HelpFormula(
        tex: r'\sigma_{cr} = \frac{P_{cr}}{A}, \quad '
            r'\lambda = \frac{KL}{r}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'σcr = Pcr / A，λ = K·L / r，r = √(I/A)',
        caption: '臨界應力與長細比',
      ),
    ],
    symbols: [
      HelpSymbol('Pcr', '臨界（歐拉）屈曲載荷', 'N'),
      HelpSymbol('E', '彈性模量', 'MPa'),
      HelpSymbol('I', '最小慣性矩', 'mm⁴'),
      HelpSymbol('K', '計算長度係數，由桿端約束決定'),
      HelpSymbol('L', '無支撐長度', 'mm'),
      HelpSymbol('λ', '長細比'),
    ],
    notes: [
      '應取截面最小的 I：壓桿總是繞最弱的軸屈曲，而不管你原本預期它往哪邊彎。',
      '理論 K 值：兩端鉸支 1.0，兩端固定 0.5，一端固定一端鉸支 0.7，一端固定一端自由 2.0。'
          '設計規範取值大於理論值，因為實際桿端從來不是理想固定。',
      '歐拉公式只適用於細長桿。當 σcr 超過屈服強度的約一半時進入非彈性屈曲，'
          '應改用 Johnson 拋物線公式或規範中的柱子曲線。',
      '假定桿件絕對平直且載荷嚴格居中。實際的初彎曲和偏心會降低承載力，'
          '規範中的安全係數正是為此而設。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 13',
      'AISC Steel Construction Manual, ch. E',
    ],
    diagram: 'images/buckling/icon_buckling_pinned_pinned.png',
  ),
  120: ToolHelp(
    summary: '螺栓或鉚釘搭接接頭在板件和緊固件上的三種失效方式：'
        '螺栓被剪斷、板件被螺栓擠壓壓潰、以及板件沿邊緣被撕脫。'
        '三者同時校核，因為接頭的承載力取決於其中最弱的一種。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{P}{n\,m\,\frac{\pi d^2}{4}}',
        plain: 'τ = P / (n·m·π·d²/4)',
        caption: '螺栓剪切；m = 1 為單剪，2 為雙剪',
      ),
      HelpFormula(
        tex: r'\sigma_b = \frac{P}{n\,d\,t}',
        plain: 'σb = P / (n·d·t)',
        caption: '按投影面積計算的擠壓應力',
      ),
      HelpFormula(
        tex: r'\tau_{to} = \frac{P}{2n\left(e-\frac{d}{2}\right)t}',
        plain: 'τto = P / [2·n·(e − d/2)·t]',
        caption: '沿兩個剪切面撕脫至邊緣',
      ),
    ],
    symbols: [
      HelpSymbol('P', '接頭承受的載荷', 'N'),
      HelpSymbol('n', '緊固件數量'),
      HelpSymbol('m', '每個緊固件的剪切面數：1 或 2'),
      HelpSymbol('d', '緊固件直徑', 'mm'),
      HelpSymbol('t', '最薄的連接板厚', 'mm'),
      HelpSymbol('e', '端距，孔心到自由邊的距離', 'mm'),
    ],
    notes: [
      '這是承壓型接頭：載荷由緊固件擠壓孔壁傳遞，而不是靠摩擦。'
          '摩擦型（抗滑移）接頭按預緊力和摩擦設計，本組數值並不控制其承載力。',
      '假定載荷在各緊固件間均分。對短而緊湊的螺栓群這是合理的；'
          '對一長排螺栓則偏樂觀，兩端的緊固件受力更大。',
      '板件淨截面的拉斷是第四種失效方式，本工具不作校核——'
          '應扣除孔面積後單獨驗算。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'AISC Steel Construction Manual, ch. J3',
    ],
  ),
  121: ToolHelp(
    summary: '把作用於同一點的軸向、彎曲和扭轉載荷合成為一個正應力和一個剪應力。'
        '只要保持線彈性，疊加原理即成立，所得的這一對應力正是強度理論所需要的輸入。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A} + \frac{Mc}{I}',
        plain: 'σ = P/A + M·c/I',
        caption: '正應力：軸向加彎曲',
      ),
      HelpFormula(
        tex: r'\tau = \frac{Tr}{J}',
        plain: 'τ = T·r / J',
        caption: '扭轉引起的剪應力',
      ),
    ],
    symbols: [
      HelpSymbol('P', '軸向力，受拉為正', 'N'),
      HelpSymbol('A', '橫截面積', 'mm²'),
      HelpSymbol('M', '彎矩', 'N·mm'),
      HelpSymbol('c', '中性軸到所求點的距離', 'mm'),
      HelpSymbol('I', '繞彎曲軸的慣性矩', 'mm⁴'),
      HelpSymbol('T', '扭矩', 'N·mm'),
      HelpSymbol('r', '所求點的半徑', 'mm'),
      HelpSymbol('J', '極慣性矩', 'mm⁴'),
    ],
    notes: [
      '疊加需要線彈性和小變形。細長構件受壓時撓度本身還會產生附加彎矩（P–δ 效應），'
          '本工具不予考慮。',
      '彎曲引起的橫向剪應力是另一回事，它在中性軸處最大，而那裡彎曲應力為零。'
          '兩個位置都要校核，不能只看最外層纖維。',
      '與 mm 和 MPa 配套時，彎矩應取 N·mm。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
  ),

  102: ToolHelp(
    summary: '各種標準截面繞形心軸的慣性矩。I 是決定截面抗彎剛度以及在給定彎矩下'
        '應力大小的几何量——工字鋼之所以高效、扁鋼之所以不行，原因都在於它。',
    formulas: [
      HelpFormula(
        tex: r'I_x = \frac{bh^3}{12}, \quad I_y = \frac{hb^3}{12}',
        plain: 'Ix = b·h³/12，Iy = h·b³/12',
        caption: '矩形，繞其形心軸',
      ),
      HelpFormula(
        tex: r'I = \frac{\pi d^4}{64}',
        plain: 'I = π·d⁴/64',
        caption: '實心圓',
      ),
      HelpFormula(
        tex: r'I = I_c + Ad^2',
        plain: 'I = Ic + A·d²',
        caption: '平行移軸定理，用於換算到另一根軸',
      ),
    ],
    symbols: [
      HelpSymbol('I', '慣性矩', 'mm⁴'),
      HelpSymbol('b, h', '寬度與高度', 'mm'),
      HelpSymbol('A', '面積', 'mm²'),
      HelpSymbol('d', '兩平行軸之間的距離', 'mm'),
    ],
    notes: [
      '高度項是三次方，因此增加高度比增加寬度更能提高剛度：h 加倍使 Ix 變為八倍，'
          'b 加倍只變為兩倍。',
      '平行移軸定理只能在形心軸與其平行軸之間換算。兩根都不過形心的軸之間換算時，'
          '必須先經過形心。',
      '這裡是面積矩，單位 mm⁴，不是動力學中單位為 kg·m² 的轉動慣量。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'Gere & Goodno, Mechanics of Materials, ch. 12',
    ],
    diagram: 'images/cross_section/icon_cs_rectangle.png',
  ),
  117: ToolHelp(
    summary: '截面的形心、面積、慣性矩，以及由它們導出的截面模量和回轉半徑。'
        '這些是每一項梁和柱計算都要用到的量，一并算出可以保證它們彼此一致。',
    formulas: [
      HelpFormula(
        tex: r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'ȳ = Σ(Ai·ȳi) / Σ Ai',
        caption: '組合截面的形心',
      ),
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c，r = √(I / A)',
        caption: '截面模量與回轉半徑',
      ),
    ],
    symbols: [
      HelpSymbol('ȳ', '自參考邊算起的形心位置', 'mm'),
      HelpSymbol('I', '繞形心軸的慣性矩', 'mm⁴'),
      HelpSymbol('S', '截面模量', 'mm³'),
      HelpSymbol('c', '形心到最外層纖維的距離', 'mm'),
      HelpSymbol('r', '回轉半徑', 'mm'),
    ],
    notes: [
      '截面模量用於按強度選梁（σ = M/S）；回轉半徑用於按穩定性選柱（λ = KL/r）。',
      '對於不關於彎曲軸對稱的截面，上下兩側的 c 不同，因而有兩個截面模量，'
          '取較小的那個控制設計。',
      '由裸尺寸算得的特性不含軋製圓角和焊縫金屬，因此比型鋼的公布值低几個百分點。'
          '若截面屬於標準型鋼，請使用標準截面庫。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'AISC Steel Construction Manual, Part 1',
    ],
  ),
  104: ToolHelp(
    summary: '梁截面上任意高度處的彎曲應力。應力從中性軸處的零線性增大到最外層纖維處的最大值，'
        '因此靠近中性軸的材料几乎不承擔載荷，這也是高效截面把面積儘量布置在遠離中性軸處的原因。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{My}{I}',
        plain: 'σ = M·y / I',
        caption: '距中性軸 y 處的彎曲應力',
      ),
      HelpFormula(
        tex: r'\sigma_{\max} = \frac{Mc}{I} = \frac{M}{S}',
        plain: 'σmax = M·c / I = M / S',
        caption: '最外層纖維處',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '彎曲應力，受拉為正', 'MPa'),
      HelpSymbol('M', '該截面的彎矩', 'N·mm'),
      HelpSymbol('y', '到中性軸的距離', 'mm'),
      HelpSymbol('I', '繞彎曲軸的慣性矩', 'mm⁴'),
      HelpSymbol('c', '到最外層纖維的距離', 'mm'),
    ],
    notes: [
      '歐拉–伯努利理論：平截面保持平面，材料線彈性，梁為等截面直梁。',
      '只有均質截面的純彎曲，中性軸才通過形心。軸向力會使其偏移，'
          '組合材料截面需要用換算截面法分析。',
      '繞非主軸彎曲屬於斜彎曲，本單軸公式不適用。',
      '與 mm 和 MPa 配套時，M 應取 N·mm。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 6',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
    diagram: 'images/icon_beam_bending.png',
  ),
  113: ToolHelp(
    summary: '梁截面上的橫向剪應力。它在中性軸處最大——而那裡彎曲應力恰好為零——'
        '因此兩者必須在不同高度分別校核。它對短而高的梁以及薄腹板最為重要，'
        '這類情況下剪切可能比彎曲更起控制作用。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{VQ}{It}',
        plain: 'τ = V·Q / (I·t)',
        caption: '取 Q 的那一高度處的剪應力',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{3V}{2A} \;\text{(rectangle)}, \quad '
            r'\frac{4V}{3A} \;\text{(circle)}',
        plain: 'τmax = 3V/(2A) 矩形，4V/(3A) 圓形',
        caption: '常見實心截面的峰值',
      ),
    ],
    symbols: [
      HelpSymbol('τ', '橫向剪應力', 'MPa'),
      HelpSymbol('V', '該截面的剪力', 'N'),
      HelpSymbol('Q', '所切位置以外部分面積的靜矩', 'mm³'),
      HelpSymbol('I', '整個截面的慣性矩', 'mm⁴'),
      HelpSymbol('t', '所切位置處的截面寬度', 'mm'),
    ],
    notes: [
      'Q 只取所校核高度一側的面積對中性軸的靜矩。它在中性軸處最大，在最外層纖維處為零。',
      '公式假定剪應力沿寬度 t 均匀分布。對窄腹板這很接近實際，'
          '對寬翼緣則不然，實際分布沿寬度是變化的。',
      '對工字梁，用 V 除以腹板面積的常用簡化與精確值相差僅几個百分點，設計規範正是這樣做的。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 7',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
  ),
  105: ToolHelp(
    summary: '懸臂梁在標準載荷工況下的撓度和轉角，取自經典閉式解。'
        '可用於快速校核剛度，也可用疊加法組合成更複雜的受載情況。',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{3EI}, \quad '
            r'\theta = \frac{PL^2}{2EI}',
        plain: 'δmax = P·L³/(3·E·I)，θ = P·L²/(2·E·I)',
        caption: '自由端作用集中力 P',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{wL^4}{8EI}, \quad '
            r'\theta = \frac{wL^3}{6EI}',
        plain: 'δmax = w·L⁴/(8·E·I)，θ = w·L³/(6·E·I)',
        caption: '全跨均布載荷 w',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '撓度', 'mm'),
      HelpSymbol('θ', '轉角', 'rad'),
      HelpSymbol('P', '集中力', 'N'),
      HelpSymbol('w', '分布載荷', 'N/mm'),
      HelpSymbol('L', '自固定端起的跨度', 'mm'),
      HelpSymbol('E·I', '抗彎剛度', 'N·mm²'),
    ],
    notes: [
      '撓度與 L³ 或 L⁴ 成正比。自由端受力的懸臂梁跨度加倍，柔度變為八倍——長度的影響壓倒一切。',
      '小撓度歐拉–伯努利理論，忽略剪切變形。'
          '對粗短懸臂（L/d 小於約 10）應補充剪切項。',
      '載荷可以疊加：多個載荷同時作用時，把各工況的撓度相加即可。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/cantilever_beam/icon_cantilever_beam.png',
  ),
  106: ToolHelp(
    summary: '簡支梁在標準載荷工況下的撓度和轉角，與手冊所列的閉式解相同。'
        '可用於快速校核跨度，也可用疊加法拼出更複雜的受載情況。',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{48EI}',
        plain: 'δmax = P·L³/(48·E·I)',
        caption: '跨中集中力',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{5wL^4}{384EI}',
        plain: 'δmax = 5·w·L⁴/(384·E·I)',
        caption: '全跨均布載荷',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '撓度', 'mm'),
      HelpSymbol('P', '集中力', 'N'),
      HelpSymbol('w', '分布載荷', 'N/mm'),
      HelpSymbol('L', '支座間跨度', 'mm'),
      HelpSymbol('E·I', '抗彎剛度', 'N·mm²'),
    ],
    notes: [
      '集中力偏離跨中時，最大撓度既不在力作用點，也不在跨中——'
          '但跨中值與最大值相差約 2.5% 以內，手冊因此直接給出跨中值。',
      '小撓度理論，一端鉸支一端滾動支承，因此没有軸向約束。'
          '兩端受軸向約束的梁在撓曲時會變剛，本式會高估其位移。',
      '正常使用極限通常以跨度的比例控制（樓面活載常用 L/360），而不是以應力控制。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  401: ToolHelp(
    summary: '簡支梁在集中力、全跨均布載荷或兩者共同作用下的支座反力、剪力和彎矩。'
        '剪力圖和彎矩圖告訴你該在哪個截面校核，以及校核時該用多大的 M。',
    formulas: [
      HelpFormula(
        tex: r'\sum F_y = 0, \quad \sum M = 0',
        plain: 'ΣFy = 0，ΣM = 0',
        caption: '靜力平衡，由此確定兩個支反力',
      ),
      HelpFormula(
        tex: r'V(x) = R_A - \int_0^x w\,dx, \quad M(x) = \int_0^x V\,dx',
        plain: 'V(x) = RA − ∫w dx，M(x) = ∫V dx',
        caption: '沿跨度的剪力與彎矩',
      ),
      HelpFormula(
        tex: r'M_{\max} = \frac{wL^2}{8} \;\text{(UDL)}, \quad '
            r'\frac{PL}{4} \;\text{(central point load)}',
        plain: 'Mmax = w·L²/8（均布），P·L/4（跨中集中力）',
      ),
    ],
    symbols: [
      HelpSymbol('RA, RB', '支座反力', 'N'),
      HelpSymbol('V', '剪力', 'N'),
      HelpSymbol('M', '彎矩', 'N·mm'),
      HelpSymbol('w', '均布載荷', 'N/mm'),
      HelpSymbol('L', '跨度', 'mm'),
    ],
    notes: [
      '僅限靜定情況：一端鉸支、一端滾動支承。'
          '增加第三個支座或固定端後即為超靜定，除平衡條件外還需變形協調條件。',
      '彎矩在剪力過零處取極值。那才是應當設計的截面，而對偏心載荷它並不在跨中。',
      '不計自重，除非把它計入分布載荷中。',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 4',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  400: ToolHelp(
    summary: '把平面內的共點力合成為一個合力，給出其大小和方向。'
        '這是几乎所有靜力學問題的第一步：用一個等效的力取代一組力。',
    formulas: [
      HelpFormula(
        tex: r'R_x = \sum F_i\cos\theta_i, \quad R_y = \sum F_i\sin\theta_i',
        plain: 'Rx = Σ Fi·cosθi，Ry = Σ Fi·sinθi',
        caption: '分量',
      ),
      HelpFormula(
        tex: r'R = \sqrt{R_x^2+R_y^2}, \quad '
            r'\theta_R = \operatorname{atan2}(R_y, R_x)',
        plain: 'R = √(Rx² + Ry²)，θR = atan2(Ry, Rx)',
        caption: '大小與方向',
      ),
    ],
    symbols: [
      HelpSymbol('F', '各力的大小', 'N'),
      HelpSymbol('θ', '各力的方向，自 +x 軸量起', '°'),
      HelpSymbol('R', '合力大小', 'N'),
      HelpSymbol('θR', '合力方向', '°'),
    ],
    notes: [
      '僅限共點力，即所有作用線交於一點。不共點的力還會產生力偶，'
          '若把它們簡化為作用在錯誤位置上的單個力，這個力偶就丟失了。',
      '使用 atan2 而非 arctan，以保證象限正確；單純的 arctan 無法區分 30° 與 210°。',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 2',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 2',
    ],
  ),
  402: ToolHelp(
    summary: '由矩形、圓和三角形（可含孔洞）組成的圖形的形心。'
        '形心是面積靜矩為零的位置，也是一切彎曲計算所參照的軸——'
        '形心求錯，其後的每一個應力都會錯。',
    formulas: [
      HelpFormula(
        tex: r'\bar{x} = \frac{\sum A_i \bar{x}_i}{\sum A_i}, \quad '
            r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'x̄ = Σ(Ai·x̄i)/ΣAi，ȳ = Σ(Ai·ȳi)/ΣAi',
        caption: '按面積加權的平均值',
      ),
    ],
    symbols: [
      HelpSymbol('Ai', '各部分的面積，孔洞取負', 'mm²'),
      HelpSymbol('x̄i, ȳi', '各部分自身的形心', 'mm'),
      HelpSymbol('x̄, ȳ', '整体的形心', 'mm'),
    ],
    notes: [
      '把孔洞當作帶有自身形心的負面積處理，公式即可自動照顧到它，無需特殊處理。',
      '形心一定落在任何一條對稱軸上，據此往往可以直接写出其中一個坐標而無需計算。',
      '只有密度均匀時，形心才與質心重合。',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 9',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 5',
    ],
  ),
  403: ToolHelp(
    summary: '用節點法求解平面鉸接桁架：每個節點都是處於平衡的共點力系，'
        '逐個節點求解即可得到全部桿件內力。正值為受拉，負值為受壓。',
    formulas: [
      HelpFormula(
        tex: r'\sum F_x = 0, \quad \sum F_y = 0 \;\text{at every joint}',
        plain: '每個節點滿足 ΣFx = 0 和 ΣFy = 0',
        caption: '平衡條件，每個節點兩個方程',
      ),
      HelpFormula(
        tex: r'm + r = 2j',
        plain: 'm + r = 2·j',
        caption: '靜定性判別',
      ),
    ],
    symbols: [
      HelpSymbol('m', '桿件數'),
      HelpSymbol('r', '支座反力數'),
      HelpSymbol('j', '節點數'),
    ],
    notes: [
      '假定為無摩擦鉸接且載荷只作用在節點上，因此每根桿只承受軸力。'
          '作用在桿中部的載荷還會使其彎曲，這超出本模型的範圍。',
      'm + r < 2j 為机構，無法承載；m + r > 2j 為超靜定，除平衡條件外還需桿件剛度。',
      '靜定桁架仍可能因几何布置不當而不穩定，例如三個支反力共線。'
          '數目判別是必要條件而非充分條件。',
      '受壓桿還必須校核屈曲，本工具不作此項。',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 3',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 6',
    ],
  ),
  200: ToolHelp(
    summary: '各向同性材料的三維廣義胡克定律。一個方向上的應力會通過泊松比在'
        '另外兩個方向上產生應變，因此六個分量是相互耦合的，不能逐個孤立處理。',
    formulas: [
      HelpFormula(
        tex: r'\varepsilon_x = \frac{1}{E}\left[\sigma_x - '
            r'\nu(\sigma_y+\sigma_z)\right]',
        plain: 'εx = [σx − ν(σy + σz)] / E',
        caption: '正應變，三式之一',
      ),
      HelpFormula(
        tex: r'\gamma_{xy} = \frac{\tau_{xy}}{G}, \quad '
            r'G = \frac{E}{2(1+\nu)}',
        plain: 'γxy = τxy / G，G = E / [2(1 + ν)]',
        caption: '剪應變，以及模量關係',
      ),
    ],
    symbols: [
      HelpSymbol('ε', '正應變'),
      HelpSymbol('γ', '工程剪應變'),
      HelpSymbol('σ, τ', '正應力與剪應力', 'MPa'),
      HelpSymbol('E', '彈性模量', 'MPa'),
      HelpSymbol('ν', '泊松比'),
      HelpSymbol('G', '剪切模量', 'MPa'),
    ],
    notes: [
      '適用於各向同性、均質、線彈性材料。複合材料、織構明顯的軋製板材和木材都不屬於此類。',
      '各向同性材料的 E、G、ν 中只有兩個獨立，第三個由前兩個決定。'
          '三個都輸入且彼此不自洽，會悄悄給出錯誤結果。',
      '熱力學穩定性要求 ν 介於 −1 與 0.5 之間。實際金屬接近 0.3，'
          '而 0.5 表示不可壓縮，橡膠接近這一數值。',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 3',
    ],
  ),
  201: ToolHelp(
    summary: '在完整的三維應力狀態與其對應的應變狀態之間雙向換算。'
        '由應變求應力的形式正是有限元後處理所需要的：網格給出的是應變，'
        '而強度準則要用的是應力。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_x = \frac{E}{(1+\nu)(1-2\nu)}\left[(1-\nu)'
            r'\varepsilon_x + \nu(\varepsilon_y+\varepsilon_z)\right]',
        plain: 'σx = E/[(1+ν)(1−2ν)] · [(1−ν)εx + ν(εy + εz)]',
        caption: '由應變求應力',
      ),
      HelpFormula(
        tex: r'\tau_{xy} = G\gamma_{xy}',
        plain: 'τxy = G · γxy',
        caption: '剪切項保持解耦',
      ),
    ],
    symbols: [
      HelpSymbol('σ, τ', '正應力與剪應力', 'MPa'),
      HelpSymbol('ε, γ', '正應變與工程剪應變'),
      HelpSymbol('E', '彈性模量', 'MPa'),
      HelpSymbol('ν', '泊松比'),
    ],
    notes: [
      '由應變求應力的形式在 ν 趨近 0.5 時發散：分母中的 (1 − 2ν) 趨於零，'
          '因為不可壓縮材料在給定應變下并無唯一的靜水壓力。'
          '近似不可壓縮的材料需要採用混合列式。',
      '工程剪應變 γ 是張量剪應變的兩倍。混用這兩種約定會造成難以察覺的二倍誤差。',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Sadd, Elasticity: Theory, Applications and Numerics, ch. 4',
    ],
  ),
  305: ToolHelp(
    summary: '由纖維和基体的性能估算單向層的剛度與密度。沿纖維方向兩相變形一致，'
        '剛度按体積加權平均；垂直纖維方向兩相共同承載，平均的是柔度，'
        '這正是橫向剛度低得多的原因。',
    formulas: [
      HelpFormula(
        tex: r'E_1 = E_f V_f + E_m(1-V_f)',
        plain: 'E1 = Ef·Vf + Em·(1 − Vf)',
        caption: '縱向——混合律',
      ),
      HelpFormula(
        tex: r'\frac{1}{E_2} = \frac{V_f}{E_f} + \frac{1-V_f}{E_m}',
        plain: '1/E2 = Vf/Ef + (1 − Vf)/Em',
        caption: '橫向——反混合律',
      ),
      HelpFormula(
        tex: r'\nu_{12} = \nu_f V_f + \nu_m(1-V_f)',
        plain: 'ν12 = νf·Vf + νm·(1 − Vf)',
        caption: '主泊松比',
      ),
    ],
    symbols: [
      HelpSymbol('E1', '沿纖維方向的剛度', 'MPa'),
      HelpSymbol('E2', '垂直纖維方向的剛度', 'MPa'),
      HelpSymbol('Vf', '纖維体積分數'),
      HelpSymbol('Ef, Em', '纖維與基体的模量', 'MPa'),
    ],
    notes: [
      'E1 相當可靠；而橫向的反混合律偏樂觀，實測值通常低於它。'
          '橫向剛度重要時，Halpin–Tsai 是標準的改進方法。',
      '這裡用的是体積分數而非質量分數。供應商常給出質量分數，'
          '使用前請用兩者的密度換算。',
      '成型良好的層合板 Vf 上限約 0.65；再高就没有足夠的基体浸潤纖維了。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 3',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 3',
    ],
    diagram: 'images/lamina.png',
  ),
  301: ToolHelp(
    summary: '正交異性單層的四個獨立工程彈性常數——兩個模量、一個剪切模量和一個泊松比——'
        '以及由它們組成的柔度矩陣。所有層合板計算都從這裡開始。',
    formulas: [
      HelpFormula(
        tex: r'\frac{\nu_{12}}{E_1} = \frac{\nu_{21}}{E_2}',
        plain: 'ν12 / E1 = ν21 / E2',
        caption: '互等關係，它保證柔度矩陣對稱',
      ),
      HelpFormula(
        tex: r'Q_{11} = \frac{E_1}{1-\nu_{12}\nu_{21}}, \quad '
            r'Q_{22} = \frac{E_2}{1-\nu_{12}\nu_{21}}, \quad Q_{66} = G_{12}',
        plain: 'Q11 = E1/(1 − ν12·ν21)，Q22 = E2/(1 − ν12·ν21)，Q66 = G12',
        caption: '折減剛度',
      ),
    ],
    symbols: [
      HelpSymbol('E1, E2', '縱向與橫向模量', 'MPa'),
      HelpSymbol('G12', '面內剪切模量', 'MPa'),
      HelpSymbol('ν12', '主泊松比'),
      HelpSymbol('Q', '折減剛度矩陣各項', 'MPa'),
    ],
    notes: [
      '平面應力下只有四個常數獨立，ν21 由互等關係確定。'
          '若另行輸入實測的、與之不符的 ν21，會使矩陣不對稱而失去物理意義。',
      'ν12 表示沿方向 1 加載所引起的方向 2 的收縮。'
          '下標順序是複合材料中最常見的混淆之處，部分教材的約定恰好相反。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 4',
    ],
    diagram: 'images/lamina.png',
  ),
  300: ToolHelp(
    summary: '單層在材料主軸或任意轉角坐標系下的應力與應變。'
        '由於單層沿纖維方向遠比橫向剛硬，轉角帶來的不只是數值的旋轉：'
        '偏軸鋪層會把正應力與剪應變耦合起來。',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}\sigma_1\\\sigma_2\\\tau_{12}\end{bmatrix} = '
            r'[Q]\begin{bmatrix}\varepsilon_1\\\varepsilon_2\\'
            r'\gamma_{12}\end{bmatrix}',
        plain: '{σ1, σ2, τ12} = [Q] · {ε1, ε2, γ12}',
        caption: '材料主軸坐標系下',
      ),
      HelpFormula(
        tex: r'[\bar{Q}] = [T]^{-1}[Q][T]^{-T}',
        plain: '[Q̄] = [T]⁻¹ [Q] [T]⁻ᵀ',
        caption: '轉換到層合板坐標系',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '沿纖維與垂直纖維方向的應力', 'MPa'),
      HelpSymbol('τ12', '面內剪應力', 'MPa'),
      HelpSymbol('[Q]', '折減剛度矩陣', 'MPa'),
      HelpSymbol('θ', '相對層合板 x 軸的鋪層角', '°'),
    ],
    notes: [
      '單層按平面應力處理：忽略厚度方向應力。'
          '這在薄層合板內部是合理的，在自由邊緣則不成立，而分層正是從那裡開始的。',
      'θ 只要不是 0° 或 90°，轉換後的矩陣就會出現非零的 Q̄16 和 Q̄26，'
          '即剪切–拉伸耦合。這是真實存在的效應，不是數值假象。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 5',
    ],
    diagram: 'images/lamina.png',
  ),
  302: ToolHelp(
    summary: '經典層合板理論：把各鋪層組裝成 A、B、D 矩陣，'
        '把面內力和彎矩與中面應變和曲率聯系起來。'
        '正是它把一疊鋪層變成一種性能可預測的結構材料。',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}N\\M\end{bmatrix} = '
            r'\begin{bmatrix}A & B\\B & D\end{bmatrix}'
            r'\begin{bmatrix}\varepsilon^0\\\kappa\end{bmatrix}',
        plain: '{N, M} = [[A, B], [B, D]] · {ε⁰, κ}',
        caption: '層合板本構關係',
      ),
      HelpFormula(
        tex: r'A_{ij}=\sum \bar{Q}_{ij}(z_k-z_{k-1}), \quad '
            r'B_{ij}=\tfrac{1}{2}\sum \bar{Q}_{ij}(z_k^2-z_{k-1}^2), \quad '
            r'D_{ij}=\tfrac{1}{3}\sum \bar{Q}_{ij}(z_k^3-z_{k-1}^3)',
        plain: 'Aij = ΣQ̄ij·(zk − zk−1)；Bij = ½ΣQ̄ij·(zk² − zk−1²)；'
            'Dij = ⅓ΣQ̄ij·(zk³ − zk−1³)',
        caption: '拉伸、耦合與彎曲剛度',
      ),
    ],
    symbols: [
      HelpSymbol('N', '單位寬度上的面內力', 'N/mm'),
      HelpSymbol('M', '單位寬度上的彎矩', 'N·mm/mm'),
      HelpSymbol('ε⁰', '中面應變'),
      HelpSymbol('κ', '曲率', '1/mm'),
      HelpSymbol('z', '鋪層界面相對中面的高度', 'mm'),
    ],
    notes: [
      '當且僅當鋪層關於中面對稱時 B 才為零。非零的 B 會把拉伸與彎曲耦合起來，'
          '零件在固化冷却時就會翹曲——這正是實際層合板几乎都做成對稱鋪層的原因。',
      '經典層合板理論忽略橫向剪切，因此會高估厚層合板以及軟芯夾層板的剛度。',
      '不含固化產生的殘餘熱應力，而它可能占首層失效載荷的相當大一部分。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  303: ToolHelp(
    summary: '層合板的等效面內工程常數——即把整疊鋪層當作均質薄板測試時所得到的模量。'
        '便於與金屬作對比，也便於把層合板輸入只接受單一材料的分析程序。',
    formulas: [
      HelpFormula(
        tex: r'E_x = \frac{1}{h\,a_{11}}, \quad E_y = \frac{1}{h\,a_{22}}, '
            r'\quad G_{xy} = \frac{1}{h\,a_{66}}',
        plain: 'Ex = 1/(h·a11)，Ey = 1/(h·a22)，Gxy = 1/(h·a66)',
        caption: '由拉伸剛度的逆 [a] = [A]⁻¹ 求得',
      ),
      HelpFormula(
        tex: r'\nu_{xy} = -\frac{a_{12}}{a_{11}}',
        plain: 'νxy = −a12 / a11',
      ),
    ],
    symbols: [
      HelpSymbol('Ex, Ey', '等效面內模量', 'MPa'),
      HelpSymbol('Gxy', '等效面內剪切模量', 'MPa'),
      HelpSymbol('h', '層合板總厚度', 'mm'),
      HelpSymbol('[a]', 'A 矩陣的逆', 'mm/N'),
    ],
    notes: [
      '這些常數只描述面內行為。彎曲剛度來自 D，'
          '同樣的鋪層換一個順序，A 不變而 D 會變——鋪層順序對彎曲有影響，對拉伸没有。',
      '只有對稱層合板才有意義。B 矩陣非零時，鋪層根本不像一塊均質薄板那樣表現。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  304: ToolHelp(
    summary: '層合板的三維等效性能，包含經典層合板理論所略去的厚度方向各項。'
        '在零件較厚、存在面外載荷，或需要建立實体有限元模型時需要它們。',
    formulas: [
      HelpFormula(
        tex: r'[C] = [S]^{-1}',
        plain: '[C] = [S]⁻¹',
        caption: '剛度是組裝後柔度矩陣的逆',
      ),
    ],
    symbols: [
      HelpSymbol('[C]', '6×6 剛度矩陣', 'MPa'),
      HelpSymbol('[S]', '6×6 柔度矩陣', '1/MPa'),
      HelpSymbol('E3', '厚度方向模量', 'MPa'),
      HelpSymbol('G13, G23', '橫向剪切模量', 'MPa'),
    ],
    notes: [
      '厚度方向的性能由基体控制，數值很低，往往比 E1 低兩個數量級。'
          '這正是複合材料以分層方式而非屈服方式失效的原因。',
      '三維等效性能把層合板抹平成一塊均質各向異性實体。'
          '這對整体剛度是合適的，但對自由邊緣的層間應力毫無用處，那需要逐層模型。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Herakovich, Mechanics of Fibrous Composites, ch. 3',
    ],
    diagram: 'images/laminate.png',
  ),
  306: ToolHelp(
    summary: '單向層在複合應力下的首層失效準則。'
        'Tsai–Hill 和 Tsai–Wu 是相互作用的二次型準則；'
        '最大應力和最大應變準則則逐個分量校核，并能指出是哪種模式失效。',
    formulas: [
      HelpFormula(
        tex: r'\left(\frac{\sigma_1}{X}\right)^2 - '
            r'\frac{\sigma_1\sigma_2}{X^2} + '
            r'\left(\frac{\sigma_2}{Y}\right)^2 + '
            r'\left(\frac{\tau_{12}}{S}\right)^2 = 1',
        plain: '(σ1/X)² − σ1σ2/X² + (σ2/Y)² + (τ12/S)² = 1',
        caption: 'Tsai–Hill',
      ),
      HelpFormula(
        tex: r'F_1\sigma_1 + F_2\sigma_2 + F_{11}\sigma_1^2 + '
            r'F_{22}\sigma_2^2 + F_{66}\tau_{12}^2 + '
            r'2F_{12}\sigma_1\sigma_2 = 1',
        plain: 'F1σ1 + F2σ2 + F11σ1² + F22σ2² + F66τ12² + 2F12σ1σ2 = 1',
        caption: 'Tsai–Wu，可區分拉伸與壓縮',
      ),
    ],
    symbols: [
      HelpSymbol('X', '縱向強度', 'MPa'),
      HelpSymbol('Y', '橫向強度', 'MPa'),
      HelpSymbol('S', '面內剪切強度', 'MPa'),
      HelpSymbol('σ1, σ2, τ12', '材料主軸下的單層應力', 'MPa'),
    ],
    notes: [
      '這些準則預測的是首層失效，而不是層合板的最終破壞。'
          '首層開裂後層合板通常還能繼續承受相當大的載荷，'
          '求真正的極限承載力需要漸進失效分析。',
      '應根據應力的正負分別取拉伸或壓縮強度。Tsai–Hill 的基本形式不會自動這樣做。',
      'Tsai–Wu 需要相互作用項 F12，而它很難測定；'
          'F12 = −½√(F11·F22) 是常用且合理的默認取值。',
      '這些準則都不說明單層是"怎樣"失效的。最大應力準則能說明，'
          '因此仍值得同時計算。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Tsai & Wu, "A General Theory of Strength for Anisotropic Materials", '
          'J. Composite Materials, 1971',
    ],
    diagram: 'images/lamina.png',
  ),

  701: ToolHelp(
    summary: '圓截面鋼絲螺旋壓縮彈簧：彈簧指數、計入曲率和直接剪切的 Wahl 修正係數、'
        '剛度以及顫振頻率。需要留意的是彈簧指數 C——小於約 4 捲製困難，'
        '大於 12 則容易纏繞和失穩。',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{D}{d}, \quad '
            r'K_W = \frac{4C-1}{4C-4} + \frac{0.615}{C}',
        plain: 'C = D/d，KW = (4C − 1)/(4C − 4) + 0.615/C',
        caption: '彈簧指數與 Wahl 係數',
      ),
      HelpFormula(
        tex: r'\tau = K_W \frac{8FD}{\pi d^3}',
        plain: 'τ = KW · 8·F·D / (π·d³)',
        caption: '修正後的鋼絲剪應力',
      ),
      HelpFormula(
        tex: r'k = \frac{Gd^4}{8D^3N_a}',
        plain: 'k = G·d⁴ / (8·D³·Na)',
        caption: '彈簧剛度',
      ),
    ],
    symbols: [
      HelpSymbol('d', '鋼絲直徑', 'mm'),
      HelpSymbol('D', '中徑', 'mm'),
      HelpSymbol('C', '彈簧指數'),
      HelpSymbol('Na', '有效圈數'),
      HelpSymbol('G', '鋼絲剪切模量', 'MPa'),
      HelpSymbol('k', '彈簧剛度', 'N/mm'),
    ],
    notes: [
      'D 是中徑，即外徑減去一個鋼絲直徑。誤用外徑會明顯高估剛度。',
      '有效圈數少於總圈數：併緊磨平的端部約少兩圈，不併緊的端部則几乎不少。',
      '工作頻率應遠離顫振頻率——氣門彈簧通常要求相差 15 至 20 倍。'
          '顫振是沿彈簧傳播的波，而不是剛体振型。',
      '鋼絲強度與直徑關係很大：同種合金的細絲比粗絲強得多。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 10',
      'Wahl, Mechanical Springs',
    ],
  ),
  702: ToolHelp(
    summary: '20° 標準齒形漸開線直齒圓柱齒輪副的几何參數——分度圓直徑、中心距和傳動比——'
        '以及 Lewis 彎曲應力估算和簡化的接觸應力值。這是初步選型，而非 AGMA 承載能力校核。',
    formulas: [
      HelpFormula(
        tex: r'd = mN, \quad C = \frac{d_1+d_2}{2}, \quad '
            r'i = \frac{N_2}{N_1}',
        plain: 'd = m·N，C = (d1 + d2)/2，i = N2/N1',
        caption: '分度圓直徑、中心距、傳動比',
      ),
      HelpFormula(
        tex: r'\sigma = \frac{W_t}{b\,m\,Y}',
        plain: 'σ = Wt / (b·m·Y)',
        caption: '齒根 Lewis 彎曲應力',
      ),
    ],
    symbols: [
      HelpSymbol('m', '模數', 'mm'),
      HelpSymbol('N', '齒數'),
      HelpSymbol('d', '分度圓直徑', 'mm'),
      HelpSymbol('Wt', '切向齒面力', 'N'),
      HelpSymbol('b', '齒寬', 'mm'),
      HelpSymbol('Y', 'Lewis 齒形係數'),
    ],
    notes: [
      'Lewis 公式把單個輪齒當作靜載懸臂梁。它不計齒根圓角處的應力集中、'
          '動載效應、多齒分擔載荷和安裝誤差——而 AGMA 2001 用一系列明確的係數考慮了這些，'
          '真正的承載能力校核也離不開它們。',
      '20° 標準齒形的小齒輪齒數少於 17 會發生根切，再少就需要變位。',
      '接觸（赫茲）應力通常控制齒面耐久性，彎曲應力控制輪齒折斷。'
          '兩者都要校核，它們的失效方式不同。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 13–14',
      'ANSI/AGMA 2001-D04',
    ],
  ),
  703: ToolHelp(
    summary: '在彎曲交變、扭轉穩定的複合載荷下，按畸變能理論結合修正 Goodman 準則'
        '求軸的最小直徑。這是最常見工況——旋轉軸彎曲完全對稱循環、扭矩恆定——'
        '的標準軸徑計算式。',
    formulas: [
      HelpFormula(
        tex: r'd = \left(\frac{16n}{\pi}\left\{\frac{1}{S_e}\left[4(K_f '
            r'M_a)^2 + 3(K_{fs}T_a)^2\right]^{1/2} + \frac{1}{S_{ut}}'
            r'\left[4(K_f M_m)^2 + 3(K_{fs}T_m)^2\right]^{1/2}\right\}'
            r'\right)^{1/3}',
        plain: 'd = { (16n/π) · [ (1/Se)·√(4(Kf·Ma)² + 3(Kfs·Ta)²) '
            '+ (1/Sut)·√(4(Kf·Mm)² + 3(Kfs·Tm)²) ] }^(1/3)',
        caption: 'DE–Goodman 軸徑公式',
      ),
    ],
    symbols: [
      HelpSymbol('Ma, Mm', '交變與平均彎矩', 'N·m'),
      HelpSymbol('Ta, Tm', '交變與平均扭矩', 'N·m'),
      HelpSymbol('Se', '修正後的持久極限', 'MPa'),
      HelpSymbol('Sut', '抗拉強度', 'MPa'),
      HelpSymbol('Kf, Kfs', '疲勞應力集中係數'),
      HelpSymbol('n', '設計係數'),
    ],
    notes: [
      '旋轉軸承受不變的橫向載荷時，彎曲是完全對稱循環：Ma 取全部彎矩，Mm 為零。'
          '恆定驅動產生的扭矩正好相反，只有 Tm。',
      'Kf 和 Kfs 是危險截面處的疲勞係數，通常出現在軸肩圓角、鍵槽或過盈配合處。'
          '取 1 偏樂觀，尖銳軸肩很容易達到 2。',
      '本式只按疲勞強度定尺寸。還應校核撓度、軸承處的轉角和臨界轉速——'
          '通過本校核的軸仍可能無法使用。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'ANSI/ASME B106.1M, Design of Transmission Shafting',
    ],
  ),
  704: ToolHelp(
    summary: '滾動軸承的基本額定壽命：同一批軸承中 90% 能夠達到的轉數。'
        '指數使壽命對載荷極為敏感——載荷減半，球軸承壽命變為八倍。',
    formulas: [
      HelpFormula(
        tex: r'L_{10} = \left(\frac{C}{P}\right)^{p}',
        plain: 'L10 = (C/P)^p，球軸承 p = 3，滾子軸承 p = 10/3',
        caption: '額定壽命，單位為百萬轉',
      ),
      HelpFormula(
        tex: r'L_{10h} = \frac{10^6 L_{10}}{60n}',
        plain: 'L10h = 10⁶ · L10 / (60·n)',
        caption: '換算為小時',
      ),
    ],
    symbols: [
      HelpSymbol('C', '基本額定動載荷，取自樣本', 'N'),
      HelpSymbol('P', '當量動載荷', 'N'),
      HelpSymbol('n', '轉速', 'rpm'),
      HelpSymbol('L10', '額定壽命', '百萬轉'),
    ],
    notes: [
      'L10 的含義是到該時刻預計已有 10% 失效，而不是軸承能用那么久。'
          '中位壽命約為 L10 的五倍。',
      'P 是當量載荷 P = X·Fr + Y·Fa，用樣本係數把徑向和軸向分量合成，'
          '在存在軸向力時並不等於徑向載荷。',
      '基本額定壽命不考慮潤滑、污染和溫度。ISO 281 為此引入壽命修正係數 a-ISO，'
          '潤滑不良的軸承可能遠達不到 L10。',
      'C 必須是動載荷額定值。靜載荷額定值 C0 控制靜止軸承的壓痕，是另一個量。',
    ],
    references: [
      'ISO 281, Rolling bearings — Dynamic load ratings and rating life',
      'Shigley, Mechanical Engineering Design, ch. 11',
    ],
  ),
  705: ToolHelp(
    summary: '開口帶傳動或滾子鏈傳動的几何參數：傳動比、帶長以及各輪上的包角。'
        '小帶輪的包角決定摩擦型帶傳動在打滑前所能傳遞的最大扭矩。',
    formulas: [
      HelpFormula(
        tex: r'i = \frac{D_2}{D_1} = \frac{n_1}{n_2}',
        plain: 'i = D2/D1 = n1/n2',
        caption: '傳動比',
      ),
      HelpFormula(
        tex: r'L = 2C + \frac{\pi}{2}(D_1+D_2) + \frac{(D_2-D_1)^2}{4C}',
        plain: 'L = 2C + (π/2)(D1 + D2) + (D2 − D1)²/(4C)',
        caption: '開口帶長度',
      ),
      HelpFormula(
        tex: r'\theta_1 = \pi - 2\arcsin\frac{D_2-D_1}{2C}',
        plain: 'θ1 = π − 2·arcsin[(D2 − D1)/(2C)]',
        caption: '小帶輪包角',
      ),
    ],
    symbols: [
      HelpSymbol('D1, D2', '小輪與大輪的節圓直徑', 'mm'),
      HelpSymbol('C', '中心距', 'mm'),
      HelpSymbol('L', '帶長', 'mm'),
      HelpSymbol('θ1', '小帶輪包角', 'rad'),
    ],
    notes: [
      '帶長表達式是標準近似式，當 C 大於約 (D1 + D2) 時非常接近精確值。',
      '小帶輪包角應保持在約 120° 以上。低於此值時，平帶或 V 帶在達到額定能力前就會打滑，'
          '通常用張緊輪來解決。',
      '滾子鏈應使用節圓直徑，并把鏈長圓整為偶數個節距——奇數節需要過渡鏈節，強度較低。',
      '僅為几何計算：帶的傳遞功率能力取決於型號、線速度和制造商樣本中的工況係數。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 17',
      'ANSI/ASME B29.1, Precision Power Transmission Roller Chains',
    ],
  ),
  706: ToolHelp(
    summary: '用簡化的扭矩–預緊力關係式，求達到目標預緊力所需的擰緊力矩。'
        '真正把接頭夾緊的是預緊力，而扭矩只是它的間接量度——而且是很不精確的量度，'
        '因此這個數值需要謹慎對待。',
    formulas: [
      HelpFormula(
        tex: r'T = K F_i d',
        plain: 'T = K · Fi · d',
        caption: '達到目標預緊力所需的力矩',
      ),
      HelpFormula(
        tex: r'F_i \approx 0.75 A_t S_p \;\text{(reused)}, \quad '
            r'0.90 A_t S_p \;\text{(permanent)}',
        plain: 'Fi ≈ 0.75·At·Sp（可重複使用），0.90·At·Sp（永久連接）',
        caption: '常用的預緊力目標值',
      ),
    ],
    symbols: [
      HelpSymbol('T', '擰緊力矩', 'N·m'),
      HelpSymbol('K', '扭矩係數，無鍍層鋼約 0.20'),
      HelpSymbol('Fi', '目標預緊力', 'N'),
      HelpSymbol('d', '螺栓公稱直徑', 'mm'),
      HelpSymbol('At', '公稱應力面積', 'mm²'),
      HelpSymbol('Sp', '保證應力', 'MPa'),
    ],
    notes: [
      'K 把螺紋摩擦和支承面摩擦合在一起，是本方法最薄弱的環節：'
          '它隨鍍層、潤滑和重複使用而變化，僅靠扭矩控制時預緊力的離散度通常達 ±25–30%。',
      '輸入力矩中約 90% 消耗在摩擦上，只有約 10% 轉化為拉力。'
          '因此摩擦的微小變化會引起預緊力的很大變化。',
      '預緊力真正重要時，應直接測量——過貼合點後的轉角控制、螺栓伸長測量'
          '或指示墊圈——而不要依賴扭矩。',
      '應使用公稱應力面積 At，而不是光桿面積。M10 粗牙的 At 為 58 mm²，'
          '而按公稱直徑計算是 78.5 mm²。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'Bickford, An Introduction to the Design and Behavior of Bolted Joints',
    ],
  ),
  707: ToolHelp(
    summary: '角焊縫焊喉上的剪應力。焊喉是焊縫中最小的截面，因而是破壞面；'
        '設計實踐中不論接頭如何受載，都按焊喉受剪來校核角焊縫。',
    formulas: [
      HelpFormula(
        tex: r'a = 0.707\,w, \quad \tau = \frac{F}{a L}',
        plain: 'a = 0.707·w，τ = F / (a·L)',
        caption: '焊喉厚度及其上的剪應力',
      ),
    ],
    symbols: [
      HelpSymbol('w', '角焊縫焊脚尺寸', 'mm'),
      HelpSymbol('a', '有效焊喉，等腰角焊縫為 0.707·w', 'mm'),
      HelpSymbol('L', '有效焊縫長度', 'mm'),
      HelpSymbol('F', '焊縫組承受的載荷', 'N'),
    ],
    notes: [
      '把所有角焊縫都按焊喉受剪處理是標準簡化。實際上橫向受載的角焊縫'
          '比縱向的強約 50%，規範允許用方向強度係數計入這一點。',
      '0.707 係數適用於焊面平齊的等腰角焊縫。凸面或不等腰焊縫的焊喉不同。',
      '這裡只考慮軸心受載。偏心載荷會在焊縫組上附加扭轉或彎曲分量，'
          '必須與直接剪力按矢量合成。',
      '焊材強度通常與母材等強或略高，因此除非焊脚偏小，焊縫一般不起控制作用。',
    ],
    references: [
      'AWS D1.1, Structural Welding Code — Steel',
      'Shigley, Mechanical Engineering Design, ch. 9',
    ],
  ),
  708: ToolHelp(
    summary: '實心軸壓入同種材料輪轂時的接觸壓力、輪轂環向應力和軸內應力。'
        '過盈配合是大多數齒輪和聯軸器的實際連接方式——没有鍵槽，也就没有應力集中源。',
    formulas: [
      HelpFormula(
        tex: r'p = \frac{E\delta}{2d}\left[\frac{d_o^2-d^2}{d_o^2}\right]',
        plain: 'p = (E·δ / 2d) · (do² − d²)/do²',
        caption: '接觸壓力，兩件同種材料',
      ),
      HelpFormula(
        tex: r'\sigma_{h} = p\,\frac{d_o^2+d^2}{d_o^2-d^2}, \quad '
            r'\sigma_{\text{shaft}} = -p',
        plain: 'σh = p·(do² + d²)/(do² − d²)，σshaft = −p',
        caption: '輪轂孔壁環向應力，以及軸內的均匀受壓狀態',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '直徑過盈量', 'mm'),
      HelpSymbol('d', '配合面公稱直徑', 'mm'),
      HelpSymbol('do', '輪轂外徑', 'mm'),
      HelpSymbol('p', '接觸壓力', 'MPa'),
      HelpSymbol('E', '彈性模量，按 GPa 輸入', 'GPa'),
    ],
    notes: [
      '軸與輪轂同種材料，泊松比才能約去。異種材料需要用一般的拉梅公式，'
          '而鋼軸裝在鋁輪轂裡會隨溫度升高而鬆脫。',
      '輪轂孔壁的環向應力為拉應力，是接頭中最大的應力。'
          '使薄壁輪轂開裂的是它，而不是接觸壓力。',
      '過盈量應按"配合"確定而非取名義值：實際過盈量在公差帶內變化，'
          '兩個極端都要校核——最小過盈校核傳扭能力，最大過盈校核輪轂應力。',
      '裝配時表面粗糙度會被壓平，從而減小有效過盈量，應留出几個微米的餘量。',
      '接頭能傳遞的扭矩為 μ·p·π·d²·L/2，本工具不計算——'
          '它需要摩擦係數和配合長度，而這兩項都不在輸入之列。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 3 and 7',
      'ISO 286-1, Geometrical product specifications: ISO code system',
    ],
  ),
  709: ToolHelp(
    summary: '裝有一個轉子的軸的一階橫向臨界轉速，'
        '用鄧克利公式把轉子的渦動頻率與軸自身分布質量的影響合成。'
        '在臨界轉速下運行時，微小的不平衡就會引起很大的撓度。',
    formulas: [
      HelpFormula(
        tex: r'\omega_r = \sqrt{\frac{k}{m}}, \quad '
            r'\frac{1}{\omega_c^2} = \frac{1}{\omega_r^2} + '
            r'\frac{1}{\omega_s^2}',
        plain: 'ωr = √(k/m)，1/ωc² = 1/ωr² + 1/ωs²',
        caption: '用鄧克利公式合成轉子與軸',
      ),
      HelpFormula(
        tex: r'N_c = \frac{60\,\omega_c}{2\pi}',
        plain: 'Nc = 60·ωc / (2π)',
        caption: '臨界轉速，單位 rpm',
      ),
    ],
    symbols: [
      HelpSymbol('k', '轉子處的橫向剛度', 'N/mm'),
      HelpSymbol('m', '轉子質量', 'kg'),
      HelpSymbol('ωc', '一階臨界角頻率', 'rad/s'),
      HelpSymbol('Nc', '一階臨界轉速', 'rpm'),
    ],
    notes: [
      '鄧克利公式總是偏低，因此給出的臨界轉速是保守的。這正是有利的偏保守方向。',
      '工作轉速應留有充分裕度——通常低於一階臨界的約 75%，或高於其約 140%。'
          '升速過程中快速穿越臨界轉速是可以接受的。',
      '假定軸承為剛性。軸承或軸承座偏軟會降低臨界轉速，有時降低幅度很大。',
      '不含使臨界轉速分裂為正進動與反進動的陀螺效應。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 10',
      'Shigley, Mechanical Engineering Design, ch. 7',
    ],
  ),
  710: ToolHelp(
    summary: '等截面直梁的橫向固有頻率，涵蓋標準邊界條件下的前三階彎曲振型。'
        '固有頻率與剛度質量比的平方根成正比，與長度的平方成反比。',
    formulas: [
      HelpFormula(
        tex: r'f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}',
        plain: 'fn = (βn·L)² / (2π·L²) · √(E·I / (ρ·A))',
        caption: '歐拉–伯努利梁的頻率',
      ),
    ],
    symbols: [
      HelpSymbol('fn', '第 n 階固有頻率', 'Hz'),
      HelpSymbol('βnL', '由邊界條件確定的特征值'),
      HelpSymbol('E·I', '抗彎剛度', 'N·mm²'),
      HelpSymbol('ρ·A', '單位長度質量', 'kg/m'),
      HelpSymbol('L', '跨度', 'mm'),
    ],
    notes: [
      '歐拉–伯努利理論忽略剪切變形和轉動慣量，因此對粗短梁（L/d 小於約 10）'
          '和較高階振型給出的頻率偏高。鐵摩辛柯理論對兩者都作了修正。',
      '長度的影響占主導：跨度減半，各階頻率都提高到四倍。',
      '不屬於梁本身的附加質量——電机、充滿水的管道——會降低頻率，'
          '除非把它折算進 ρA，否則本式不予考慮。',
      '實際邊界條件從來不是理想固定或理想鉸支，真實頻率介於兩種理想化之間。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 8',
      'Blevins, Formulas for Natural Frequency and Mode Shape',
    ],
  ),
  711: ToolHelp(
    summary: '圓軸的一階扭轉固有頻率，適用於一端固定帶一個轉子，'
        '或自由軸兩端各帶一個轉子的情形。扭轉共振從外部看不出來，'
        '却是聯軸器和輪齒失效的常見原因。',
    formulas: [
      HelpFormula(
        tex: r'k_t = \frac{GJ_p}{L}, \quad '
            r'\omega_n = \sqrt{\frac{k_t}{J_{\text{eff}}}}',
        plain: 'kt = G·Jp / L，ωn = √(kt / Jeff)',
        caption: '扭轉剛度與頻率',
      ),
      HelpFormula(
        tex: r'J_{\text{eff}} = \frac{J_1 J_2}{J_1+J_2}',
        plain: 'Jeff = J1·J2 / (J1 + J2)',
        caption: '自由軸帶兩個轉子時的當量轉動慣量',
      ),
    ],
    symbols: [
      HelpSymbol('kt', '扭轉剛度', 'N·m/rad'),
      HelpSymbol('G', '剪切模量', 'MPa'),
      HelpSymbol('Jp', '軸的極慣性矩', 'mm⁴'),
      HelpSymbol('J1, J2', '兩轉子的轉動慣量', 'kg·m²'),
    ],
    notes: [
      '忽略軸自身的轉動慣量。當它與轉子相當時，應改用多質量（霍爾澤）分析。',
      'Jp 是截面特性，單位 mm⁴；J1 和 J2 是轉動慣量，單位 kg·m²。'
          '兩者只是共用一個字母，混淆它們是這裡最常見的錯誤。',
      '激勵頻率很少等於軸轉速。發動机的發火次數和齒輪嚙合頻率都是它的倍數，'
          '而與共振相遇的通常正是這些倍頻。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 5 and 6',
      'Nestorides, A Handbook on Torsional Vibration',
    ],
  ),
  800: ToolHelp(
    summary: '圓管內流動的雷諾數及其所屬流態。Re 是慣性力與黏性力之比，'
        '它單獨決定流動是有序還是紊亂，而流態又決定了摩擦係數和換熱強度。',
    formulas: [
      HelpFormula(
        tex: r'Re = \frac{\rho V D}{\mu} = \frac{VD}{\nu}',
        plain: 'Re = ρ·V·D / μ = V·D / ν',
        caption: '雷諾數',
      ),
      HelpFormula(
        tex: r'V = \frac{Q}{A}, \quad A = \frac{\pi D^2}{4}',
        plain: 'V = Q / A，A = π·D²/4',
        caption: '由体積流量求流速',
      ),
    ],
    symbols: [
      HelpSymbol('Re', '雷諾數'),
      HelpSymbol('ρ', '密度', 'kg/m³'),
      HelpSymbol('V', '平均流速', 'm/s'),
      HelpSymbol('D', '管內徑', 'mm'),
      HelpSymbol('μ', '動力黏度', 'Pa·s'),
      HelpSymbol('ν', '運動黏度，μ/ρ', 'm²/s'),
    ],
    notes: [
      '管內流動：低於約 2300 為層流，高於約 4000 為湍流，之間為過渡區。'
          '過渡並不是一個明確的界限，還與入口擾動和粗糙度有關。',
      'D 是管子的內徑，而不是公稱尺寸。請用管道壁厚系列表查得正確數值。',
      '非圓截面管道應改用水力直徑 4A/P。它對湍流效果良好，對層流則較差。',
      'V 是截面平均流速。層流時中心線流速是它的兩倍，湍流時約為 1.2 倍。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Munson, Fundamentals of Fluid Mechanics, ch. 8',
    ],
  ),
  801: ToolHelp(
    summary: '滿管流動的達西–韋斯巴赫水頭損失與壓降，摩擦係數由科爾布魯克公式求得，'
        '管件損失按速度頭的倍數計入。這是管路選徑以及為其選泵的標準方法。',
    formulas: [
      HelpFormula(
        tex: r'h_f = f\frac{L}{D}\frac{V^2}{2g}',
        plain: 'hf = f · (L/D) · V²/(2g)',
        caption: '達西–韋斯巴赫沿程水頭損失',
      ),
      HelpFormula(
        tex: r'\frac{1}{\sqrt{f}} = -2\log_{10}\left(\frac{\varepsilon/D}'
            r'{3.7} + \frac{2.51}{Re\sqrt{f}}\right)',
        plain: '1/√f = −2·log₁₀[ (ε/D)/3.7 + 2.51/(Re·√f) ]',
        caption: '科爾布魯克公式，需迭代求解',
      ),
      HelpFormula(
        tex: r'h_m = \sum K \frac{V^2}{2g}, \quad \Delta p = \rho g h',
        plain: 'hm = ΣK · V²/(2g)，Δp = ρ·g·h',
        caption: '局部損失與壓降',
      ),
    ],
    symbols: [
      HelpSymbol('f', '達西摩擦係數'),
      HelpSymbol('L', '管長', 'm'),
      HelpSymbol('D', '管內徑', 'mm'),
      HelpSymbol('ε', '絕對粗糙度', 'mm'),
      HelpSymbol('ΣK', '局部損失係數之和'),
      HelpSymbol('hf', '水頭損失', 'm'),
    ],
    notes: [
      '達西摩擦係數是範寧摩擦係數的四倍。使用圖表或關聯式前請先確認它給的是哪一個——'
          '這個四倍關係是經典錯誤來源。',
      '科爾布魯克公式適用於湍流。層流時應取 f = 64/Re，與粗糙度完全無關。',
      '常見絕對粗糙度：商用鋼管 0.045 mm，冷拔管 0.0015 mm，鑄鐵管 0.26 mm。'
          '舊管遠比新管粗糙，不確定性主要來自這裡。',
      '假定為不可壓縮流体的滿管穩定流動。半滿的重力排水管和可壓縮氣体流動'
          '需要另行處理。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Crane Technical Paper No. 410, Flow of Fluids Through Valves, '
          'Fittings and Pipe',
    ],
  ),
  802: ToolHelp(
    summary: '泵或風机所需的功率：流体獲得的是壓升乘流量，'
        '而原動机必須提供的是它除以效率。同時把壓升換算為所輸送流体的揚程，'
        '因為泵的性能曲線正是這樣繪制的。',
    formulas: [
      HelpFormula(
        tex: r'P_{\text{fluid}} = \Delta p\,Q, \quad '
            r'P_{\text{shaft}} = \frac{\Delta p\,Q}{\eta}',
        plain: 'Pfluid = Δp·Q，Pshaft = Δp·Q / η',
        caption: '水力功率與軸功率',
      ),
      HelpFormula(
        tex: r'H = \frac{\Delta p}{\rho g}',
        plain: 'H = Δp / (ρ·g)',
        caption: '把壓升表示為揚程',
      ),
    ],
    symbols: [
      HelpSymbol('Δp', '通過机器的壓升', 'kPa'),
      HelpSymbol('Q', '体積流量', 'm³/s'),
      HelpSymbol('η', '總效率'),
      HelpSymbol('H', '揚程', 'm'),
    ],
    notes: [
      '揚程與密度無關，而壓力與密度有關。同一台泵對任何液体產生的揚程相同，'
          '而對較輕的液体壓力按比例降低——泵的性能曲線用米作單位正是這個原因。',
      '這裡的效率是整机效率。若電机效率另計，還要再除以它才能得到電功率輸入。',
      '還應校核可用汽蝕餘量是否大於泵的必需汽蝕餘量。'
          '發生汽蝕的泵無論功率怎么選都無法有效輸出。',
      '對輸送空氣的風机，只有壓升較小時（低於絕對壓力的約 3%）才可按不可壓縮處理。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 11',
      'Hydraulic Institute Standards, ANSI/HI 1.1-1.2',
    ],
  ),
  810: ToolHelp(
    summary: '多層平壁的一維穩態導熱。各層是串聯的熱阻，'
        '與兩側表面的對流膜阻串聯相加，由此得到總傳熱係數、熱流量以及各界面的溫度。',
    formulas: [
      HelpFormula(
        tex: r'R_{\text{cond}} = \frac{t}{k}, \quad '
            r'R_{\text{conv}} = \frac{1}{h}',
        plain: 'Rcond = t/k，Rconv = 1/h',
        caption: '單位面積熱阻',
      ),
      HelpFormula(
        tex: r'U = \frac{1}{\sum R}, \quad q = U\,\Delta T',
        plain: 'U = 1 / ΣR，q = U · ΔT',
        caption: '總傳熱係數與熱流密度',
      ),
    ],
    symbols: [
      HelpSymbol('t', '層厚', 'm'),
      HelpSymbol('k', '導熱係數', 'W/m·K'),
      HelpSymbol('h', '對流換熱係數', 'W/m²·K'),
      HelpSymbol('U', '總傳熱係數', 'W/m²·K'),
      HelpSymbol('q', '熱流密度', 'W/m²'),
    ],
    notes: [
      '僅適用於平壁，熱阻按 t/k 相加。圓筒壁和球壁分別是對數形式和倒數形式，'
          '把平壁公式用在小直徑管道上會有明顯誤差。',
      '最大的那個熱阻起控制作用。若某面牆的熱阻已由靜止空氣膜主導，'
          '再加保溫層的效果會遠小於 k 值所暗示的。',
      '不計各層之間的接觸熱阻，而它對螺栓連接或粘接的金屬接頭可能相當重要。',
      '僅為穩態：不含熱容，因此說明不了牆体的響應時間。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'ASHRAE Handbook — Fundamentals, ch. 25',
    ],
  ),
  811: ToolHelp(
    summary: '等截面矩形直肋的效率，按絕熱肋端并採用修正長度求解。'
        '肋效率表示在肋溫沿長度下降的實際情況下，肋所達到的散熱量與理想散熱量之比。',
    formulas: [
      HelpFormula(
        tex: r'm = \sqrt{\frac{2h}{kt}}, \quad L_c = L + \frac{t}{2}',
        plain: 'm = √(2h / (k·t))，Lc = L + t/2',
        caption: '肋參數與修正長度',
      ),
      HelpFormula(
        tex: r'\eta_f = \frac{\tanh(mL_c)}{mL_c}',
        plain: 'ηf = tanh(m·Lc) / (m·Lc)',
        caption: '肋效率',
      ),
    ],
    symbols: [
      HelpSymbol('h', '對流換熱係數', 'W/m²·K'),
      HelpSymbol('k', '肋的導熱係數', 'W/m·K'),
      HelpSymbol('t', '肋厚', 'm'),
      HelpSymbol('L', '肋長', 'm'),
      HelpSymbol('ηf', '肋效率'),
    ],
    notes: [
      '修正長度是絕熱肋端解中考慮肋端對流的標準處理。'
          '當 h·t/k 較小時（通常如此）精度良好。',
      '肋越長效率越低：mLc 超過約 2 之後，再加長只增加重量而几乎不增加散熱。'
          '這就是肋高的實際上限。',
      '只有表面熱阻占主導時加肋才有意義。在 h 本已很大的換熱器水側加肋，作用很小。',
      '假定肋內為一維導熱，表面 h 均匀，且不計輻射。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'Kraus, Aziz & Welty, Extended Surface Heat Transfer',
    ],
  ),
  812: ToolHelp(
    summary: '由四個進出口溫度求對數平均溫差，以及達到給定熱負荷所需的換熱面積。'
        '對數平均溫差才是換熱器正確的平均傳熱溫差，'
        '因為局部溫差沿流程是按指數而非線性變化的。',
    formulas: [
      HelpFormula(
        tex: r'\Delta T_{lm} = \frac{\Delta T_1 - \Delta T_2}'
            r'{\ln(\Delta T_1/\Delta T_2)}',
        plain: 'ΔTlm = (ΔT1 − ΔT2) / ln(ΔT1/ΔT2)',
        caption: '對數平均溫差',
      ),
      HelpFormula(
        tex: r'A = \frac{Q}{U\,\Delta T_{lm}}',
        plain: 'A = Q / (U · ΔTlm)',
        caption: '給定熱負荷所需的面積',
      ),
    ],
    symbols: [
      HelpSymbol('ΔT1, ΔT2', '兩端的溫差', 'K'),
      HelpSymbol('U', '總傳熱係數', 'W/m²·K'),
      HelpSymbol('Q', '熱負荷', 'W'),
      HelpSymbol('A', '傳熱面積', 'm²'),
    ],
    notes: [
      '逆流是各自的進口與對方的出口配對，順流是兩個進口配對。'
          '逆流的對數平均溫差總是更大，因而換熱器更小，'
          '而且只有逆流才可能使冷流体出口溫度高於熱流体出口溫度。',
      '管殼式或錯流式布置還要乘以標準圖表中的修正係數 F。'
          'F 低於約 0.8 說明所選流程布置不合理。',
      '假定 U 和比熱沿換熱器保持不變，且無相變。'
          '一側發生冷凝或沸騰時需要分段計算。',
      '污垢會隨時間增大熱阻；設計 U 值應計入污垢裕量，否則換熱器一年內就會偏小。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 11',
      'TEMA Standards of the Tubular Exchanger Manufacturers Association',
    ],
  ),
  500: ToolHelp(
    summary: '在同一物理量的不同單位之間換算——長度、力、壓力、扭矩等。'
        '凡定義本身是精確的，換算就是精確的；對基於英寸的單位大多如此：'
        '自 1959 年起，1 英寸就精確等於 25.4 mm。',
    formulas: [
      HelpFormula(
        tex: r'v_{\text{target}} = v_{\text{source}} \times '
            r'\frac{f_{\text{source}}}{f_{\text{target}}}',
        plain: '目標值 = 源值 × (源係數 / 目標係數)',
        caption: '所有換算都經過同一個 SI 基準值',
      ),
    ],
    symbols: [
      HelpSymbol('f', '把某單位換算為其 SI 基準的係數'),
    ],
    notes: [
      '通過單一 SI 基準換算而不是單位對單位換算，意味着每個單位只需一個係數，'
          '而不是每一對單位一個，因此 n 個單位的表格不會自相矛盾。',
      '溫度是例外：°C 與 °F 之間既有比例又有偏移量，'
          '因此溫"差"的換算方式與溫度本身不同。',
      '磅力與磅質量是名稱相近的兩個不同物理量。換算前請先確認數值指的是哪一個。',
    ],
    references: [
      'BIPM, The International System of Units (SI), 9th edition',
      'NIST Special Publication 811, Guide for the Use of the SI',
    ],
  ),
  501: ToolHelp(
    summary: '標準公制和英制螺紋的底孔與過孔尺寸。'
        '底孔尺寸留下的材料約相當於 75% 的螺紋嚙合率——'
        '這是螺紋強度與攻絲扭矩之間的實用折中。',
    formulas: [
      HelpFormula(
        tex: r'd_{\text{tap}} \approx D - P',
        plain: '底孔 ≈ D − P（公制，約 75% 螺紋）',
        caption: '大徑減去一個螺距——常用的 75% 規則',
      ),
    ],
    symbols: [
      HelpSymbol('D', '螺紋公稱大徑', 'mm'),
      HelpSymbol('P', '螺距', 'mm'),
    ],
    notes: [
      'D − P 並不是小徑：基本小徑為 D − 1.0825·P，'
          '常用底孔有意留下較淺的螺紋。',
      '螺紋嚙合率從 75% 提高到 100%，強度只增加約 5%，而攻絲扭矩却几乎翻倍。'
          '這樣做几乎從不划算，而且容易斷絲錐。',
      '螺紋強度更多取決於嚙合"長度"而非嚙合百分比。'
          '在軟材料中應加長螺紋，而不是把孔攻得更深。',
      '過孔按緊、中、鬆三種配合等級選取，除非裝配需要調整餘量，一般取中等。',
      '擠壓絲錐（滾絲錐）需要比切削絲錐更大的底孔——它是擠壓材料而不是切除材料。',
    ],
    references: [
      'ISO 965-1, ISO general purpose metric screw threads — Tolerances',
      'Machinery\'s Handbook, Threads and Threading',
    ],
  ),
  502: ToolHelp(
    summary: 'ISO 286 優先選用的基孔制配合的極限偏差。'
        '一種配合是一對公差帶：字母決定公差帶相對於公稱尺寸的位置，'
        '數字決定其寬度，因此 H7/g6 與 H7/p6 的差別在位置而不在精度。',
    formulas: [
      HelpFormula(
        tex: r'\text{clearance}_{\max} = \text{hole}_{\max} - '
            r'\text{shaft}_{\min}',
        plain: '最大間隙 = 孔的最大值 − 軸的最小值',
        caption: '最小間隙則為孔的最小值 − 軸的最大值',
      ),
    ],
    symbols: [
      HelpSymbol('H', '基孔制：下偏差為零'),
      HelpSymbol('IT', '標準公差等級——公差帶的寬度'),
      HelpSymbol('µm', '偏差以微米列表'),
    ],
    notes: [
      '通常採用基孔制：孔用定尺寸刀具加工，而軸更容易調整，因此改軸更經濟。',
      '間隙為負即為過盈。H7/p6 及更緊的配合屬於壓入配合，'
          '應使用過盈配合工具校核輪轂應力。',
      '同一 IT 等級的公差帶寬度隨尺寸增大：IT7 在 20 mm 處為 21 µm，'
          '在 300 mm 處為 52 µm。',
      '表中只給出極限尺寸。軸能否裝得進去還取決於形狀誤差：'
          '圓度和直線度誤差會占用間隙。',
    ],
    references: [
      'ISO 286-1 and ISO 286-2, Geometrical product specifications',
      'Machinery\'s Handbook, Allowances and Tolerances for Fits',
    ],
  ),
  503: ToolHelp(
    summary: '熱軋型鋼的公布尺寸和截面特性——AISC 的 W 型鋼以及歐標 IPE 和 HEB。'
        '公布值包含了裸几何計算看不到的軋製圓角，這部分約占面積和剛度的百分之几。',
    formulas: [
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c，r = √(I / A)',
        caption: '截面模量與回轉半徑，二者均在此處導出',
      ),
    ],
    symbols: [
      HelpSymbol('A', '橫截面積', 'mm²'),
      HelpSymbol('Ix, Iy', '繞強軸與弱軸的慣性矩', 'mm⁴'),
      HelpSymbol('S', '彈性截面模量', 'mm³'),
      HelpSymbol('r', '回轉半徑', 'mm'),
    ],
    notes: [
      '庫中只存儲面積和兩個慣性矩，S 與 r 由它們算出，因此抄錄出錯也不會造成互相矛盾。',
      '表中收錄的是雙軸對稱的工字形截面。槽鋼和角鋼的形心不在半高處，未予收錄。',
      '這些是彈性特性。塑性設計使用塑性截面模量 Z，它更大——'
          '典型工字形截面約為 S 的 1.12 倍。',
      '出圖前請核對現行的軋製表或標準：型號偶有修訂或廢止。',
    ],
    references: [
      'AISC Steel Construction Manual, Part 1',
      'EN 10365, Hot rolled steel channels, I and H sections',
    ],
  ),
  504: ToolHelp(
    summary: 'ASME B36.10M 鋼管的外徑、壁厚和內徑。'
        '鋼管按固定外徑制造，使同一套管件和螺紋適用於各種壁厚，'
        '因此壁厚系列加大只會縮小內徑，而不會增大管子。',
    formulas: [
      HelpFormula(
        tex: r'ID = OD - 2t, \quad A = \frac{\pi\,ID^2}{4}',
        plain: 'ID = OD − 2·t，A = π·ID²/4',
        caption: '內徑與流通面積，二者均在此處導出',
      ),
    ],
    symbols: [
      HelpSymbol('NPS', '公稱管徑代號——是名稱，不是尺寸'),
      HelpSymbol('DN', 'ISO 公稱直徑，同樣是名稱'),
      HelpSymbol('OD', '外徑', 'mm'),
      HelpSymbol('t', '壁厚', 'mm'),
    ],
    notes: [
      'NPS 不是尺寸。NPS 2 的管子內徑不是 2 英寸，外徑也不是；'
          '只有 NPS 14 及以上，該數字才等於以英寸計的外徑。',
      '任何流動計算都應使用內徑而不是公稱尺寸。NPS 1 時二者相差約 5%，'
          '而在壓降計算中這一差別是按四次方放大的。',
      'STD 與 XS 分別只到 NPS 10 和 NPS 8 才與 Sch 40、Sch 80 一致；'
          '再往上，這兩個重量等級的壁厚就不再增加了。',
      '這些是公稱尺寸。壁厚的軋製負偏差通常為 −12.5%，做承壓計算時需要注意。',
    ],
    references: [
      'ASME B36.10M, Welded and Seamless Wrought Steel Pipe',
      'ASME B31.3, Process Piping',
    ],
  ),
  505: ToolHelp(
    summary: '對一列尺寸做一維公差累加，同時給出極值法和統計法（RSS）的結果。'
        '輸出封閉環間隙、它是否可能為負，以及哪一個尺寸造成了大部分變動——'
        '收緊那個尺寸的公差收益最大。',
    formulas: [
      HelpFormula(
        tex: r'g = \sum \pm d_i, \quad '
            r'T_{wc} = \sum t_i',
        plain: 'g = Σ ±di，Twc = Σ ti',
        caption: '極值法：公差按代數和相加',
      ),
      HelpFormula(
        tex: r'T_{rss} = \sqrt{\sum t_i^2}',
        plain: 'Trss = √(Σ ti²)',
        caption: 'RSS：公差按平方和相加',
      ),
    ],
    symbols: [
      HelpSymbol('di', '鏈中各尺寸的基本值', 'mm'),
      HelpSymbol('ti', '各尺寸的對稱半公差', 'mm'),
      HelpSymbol('g', '封閉環間隙', 'mm'),
    ],
    notes: [
      '極值法只是加減運算，結論無可爭辯：只要它通過，裝配就一定能裝上。應按它定尺寸。',
      'RSS 假定各尺寸獨立變動、位於公差帶中間且近似正態分布。'
          '對五件這樣的小批量它没有意義；工序發生偏移或供應商長期靠着公差帶一側生產時，'
          '它會低估變動。',
      'RSS 的占比按各公差的平方計算，因此比極值法占比更強烈地指向最鬆的那個尺寸，'
          '那就是應當收緊的對象。',
      '非對稱公差會使統計平均值偏移：25 +0.10/−0.00 實際上是 25.05 ±0.05，'
          '按 25 累加會使整條尺寸鏈偏低。',
      '僅限一維。角度影響、形狀誤差和位置度公差需要完整的三維公差分析。',
    ],
    references: [
      'ASME Y14.5, Dimensioning and Tolerancing',
      'Fischer, Mechanical Tolerance Stackup and Analysis',
    ],
  ),
};
