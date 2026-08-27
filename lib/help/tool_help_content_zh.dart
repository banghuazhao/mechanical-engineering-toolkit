import 'package:mechanical_engineering_toolkit/help/tool_help.dart';

/// Simplified Chinese tool explanations.
///
/// Equations, symbol glyphs and units are not translated: they are the same
/// notation on a drawing in every language. References stay in English
/// because they are citations — a reader looking the book up needs the title
/// it was published under.
const Map<int, ToolHelp> toolHelpZh = {
  100: ToolHelp(
    summary: '等截面直杆在轴向载荷下的单向应力与应变。正应力是载荷除以承载面积，'
        '在材料保持弹性时应变由胡克定律得出。这是其他所有应力计算的起点：'
        '拉杆、吊杆、纯受拉的螺栓都用它。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A}',
        plain: 'σ = P / A',
        caption: '正应力',
      ),
      HelpFormula(
        tex: r'\varepsilon = \frac{\sigma}{E} = \frac{\delta}{L}',
        plain: 'ε = σ / E = δ / L',
        caption: '弹性范围内的应变',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '正应力', 'MPa'),
      HelpSymbol('P', '轴向力，受拉为正', 'N'),
      HelpSymbol('A', '横截面积', 'mm²'),
      HelpSymbol('E', '弹性模量', 'MPa'),
      HelpSymbol('ε', '正应变'),
    ],
    notes: [
      '假定应力在截面上均匀分布。这在远离加载点、孔和截面突变处成立，'
          '即圣维南原理。靠近这些位置会出现本式看不到的应力集中。',
      '仅适用于弹性范围。σ 超过比例极限后 ε = σ/E 不再成立，杆件会产生残余变形。',
      '细长杆受压时，远在达到该应力之前就会屈曲。请同时使用压杆屈曲工具校核。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 1–3',
      'Gere & Goodno, Mechanics of Materials, ch. 1',
    ],
    diagram: 'images/icon_bar_force.png',
  ),
  101: ToolHelp(
    summary: '等截面直杆的轴向伸长及其对应的刚度。杆件相当于一个刚度为 AE/L 的线性弹簧，'
        '因此该关系是螺栓连接、拉杆体系以及任何用刚度叠加求解的结构的基本单元。',
    formulas: [
      HelpFormula(
        tex: r'\delta = \frac{PL}{AE}',
        plain: 'δ = P·L / (A·E)',
        caption: '伸长量',
      ),
      HelpFormula(
        tex: r'k = \frac{AE}{L}',
        plain: 'k = A·E / L',
        caption: '轴向刚度',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '伸长量，受拉为正', 'mm'),
      HelpSymbol('P', '轴向力', 'N'),
      HelpSymbol('L', '原始长度', 'mm'),
      HelpSymbol('A', '横截面积', 'mm²'),
      HelpSymbol('E', '弹性模量', 'MPa'),
      HelpSymbol('k', '轴向刚度', 'N/mm'),
    ],
    notes: [
      '适用于沿长度方向 P、A、E 均为常量的等截面杆。阶梯杆、变截面杆或计入自重时，'
          '应分段计算再把伸长量相加。',
      '小变形线弹性理论。δ 按原始长度计算，而非变形后的长度。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/bar_force_displacement.png',
  ),
  103: ToolHelp(
    summary: '圆截面轴在纯扭转下的剪应力。应力沿半径从轴心的零线性增大到表面的最大值，'
        '因此在外径相同的条件下，空心轴几乎能承受与实心轴相当的扭矩，而重量却轻得多。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{T\rho}{J}',
        plain: 'τ = T·ρ / J',
        caption: '半径 ρ 处的剪应力',
      ),
      HelpFormula(
        tex: r'J_{\text{solid}} = \frac{\pi d^4}{32}, \quad '
            r'J_{\text{hollow}} = \frac{\pi (d_o^4 - d_i^4)}{32}',
        plain: 'J = π·d⁴/32（实心），J = π·(do⁴ − di⁴)/32（空心）',
        caption: '极惯性矩',
      ),
    ],
    symbols: [
      HelpSymbol('τ', '剪应力', 'MPa'),
      HelpSymbol('T', '扭矩', 'N·mm'),
      HelpSymbol('ρ', '所求点的半径', 'mm'),
      HelpSymbol('J', '极惯性矩', 'mm⁴'),
    ],
    notes: [
      '仅适用于圆截面。非圆截面轴受扭时会发生翘曲，本式完全不适用，'
          '方形和矩形截面需要各自的扭转常数。',
      '线弹性、纯扭转。弯扭组合应先用组合受力工具，再用强度理论校核。',
      '当其他量以 mm 和 MPa 为单位时，T 应取 N·mm。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Gere & Goodno, Mechanics of Materials, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  114: ToolHelp(
    summary: '轴在扭矩作用下一端相对另一端转过的角度。扭转角决定传动轴的手感是否"发软"、'
        '扭杆能否达到设计刚度，以及在超静定系统中扭矩如何在并联路径间分配。',
    formulas: [
      HelpFormula(
        tex: r'\phi = \frac{TL}{GJ}',
        plain: 'φ = T·L / (G·J)',
        caption: '扭转角，单位为弧度',
      ),
      HelpFormula(
        tex: r'k_t = \frac{GJ}{L}',
        plain: 'kt = G·J / L',
        caption: '扭转刚度',
      ),
    ],
    symbols: [
      HelpSymbol('φ', '扭转角', 'rad'),
      HelpSymbol('T', '扭矩', 'N·mm'),
      HelpSymbol('L', '产生扭转的长度', 'mm'),
      HelpSymbol('G', '剪切模量', 'MPa'),
      HelpSymbol('J', '极惯性矩', 'mm⁴'),
    ],
    notes: [
      '适用于 T、G、J 沿长度不变的等截面圆轴。任一量发生变化时，应分段计算再把扭转角相加。',
      'G 与 E 并不独立：各向同性材料满足 G = E / [2(1 + ν)]，钢约为 0.385·E。',
      '结果以弧度表示，乘以 180/π 可换算为度。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  115: ToolHelp(
    summary: '由功率和转速求旋转轴传递的扭矩，或由已知扭矩求功率。任何轴的设计都从这里开始：'
        '电机铭牌给出功率和转速，而轴必须按由此得到的扭矩来设计。',
    formulas: [
      HelpFormula(
        tex: r'P = T\omega, \quad \omega = \frac{2\pi n}{60}',
        plain: 'P = T·ω，ω = 2π·n / 60',
        caption: '由扭矩和转速求功率',
      ),
      HelpFormula(
        tex: r'T = \frac{9549\,P_{\text{kW}}}{n}',
        plain: 'T [N·m] = 9549 · P [kW] / n [rpm]',
        caption: '工程常用形式',
      ),
    ],
    symbols: [
      HelpSymbol('P', '传递功率', 'W'),
      HelpSymbol('T', '扭矩', 'N·m'),
      HelpSymbol('ω', '角速度', 'rad/s'),
      HelpSymbol('n', '转速', 'rpm'),
    ],
    notes: [
      '这是稳定转速下传递的扭矩。启动、制动和卡死工况的扭矩可能高出数倍，'
          '设计轴之前应先乘以工况系数。',
      '功率有进有出：传动装置的损失需要单独用效率去除来考虑。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'Hibbeler, Mechanics of Materials, ch. 5',
    ],
  ),
  109: ToolHelp(
    summary: '薄壁球形压力容器壁内的薄膜应力。球是承压效率最高的形状：'
        '各个方向的应力相同，且只有相同半径和壁厚的圆筒环向应力的一半。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{pr}{2t}',
        plain: 'σ = p·r / (2·t)',
        caption: '薄膜应力，各方向相同',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '薄膜应力', 'MPa'),
      HelpSymbol('p', '内部表压', 'MPa'),
      HelpSymbol('r', '内半径', 'mm'),
      HelpSymbol('t', '壁厚', 'mm'),
    ],
    notes: [
      '薄壁理论，r/t 大于约 10 时有效。低于该值时应力沿壁厚变化，需用厚壁（拉梅）解。',
      '仅为薄膜应力。接管、支座以及与其他形状的连接处局部应力远高于此，'
          '压力容器规范的大量篇幅正是为此。',
      '按 ASME VIII 等规范设计时还需计入焊缝系数和腐蚀裕量，这里只是纯力学。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_spherical_shell_stress.png',
  ),
  110: ToolHelp(
    summary: '薄壁圆筒在内压下的环向和轴向薄膜应力。环向应力是轴向应力的两倍，'
        '这正是承压管道沿长度方向开裂、而不是沿圆周断开的原因。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_h = \frac{pr}{t}',
        plain: 'σh = p·r / t',
        caption: '环向应力',
      ),
      HelpFormula(
        tex: r'\sigma_l = \frac{pr}{2t}',
        plain: 'σl = p·r / (2·t)',
        caption: '轴向应力',
      ),
    ],
    symbols: [
      HelpSymbol('σh', '环向应力', 'MPa'),
      HelpSymbol('σl', '轴向应力', 'MPa'),
      HelpSymbol('p', '内部表压', 'MPa'),
      HelpSymbol('r', '内半径', 'mm'),
      HelpSymbol('t', '壁厚', 'mm'),
    ],
    notes: [
      '薄壁理论，r/t 大于约 10 时有效。',
      '这两个应力就是壁面上的主应力，第三个主应力约为零。把它们输入强度理论工具即可得到当量应力。',
      '只有封闭圆筒才存在轴向应力。以其他方式约束的敞口管道，其轴向载荷并不相同。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_cylindrical_pressure_stress.png',
  ),
  107: ToolHelp(
    summary: '把平面应力状态旋转到任意一组新坐标轴上。同一个物理应力状态，'
        '在不同的截面上读数并不相同；应力转换正是用来求焊缝、胶接面或纤维方向上的应力，'
        '而这些方向往往与零件的坐标轴并不一致。',
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
      HelpSymbol('σx, σy', '原坐标轴上的正应力', 'MPa'),
      HelpSymbol('τxy', '原坐标轴上的剪应力', 'MPa'),
      HelpSymbol('θ', '转到新轴的角度，逆时针为正', '°'),
    ],
    notes: [
      '平面应力：第三主应力为零。这对面内受载的薄板是好模型，对厚实体内部则不适用。',
      '符号约定：拉应力为正；剪应力作用在 +x 面上并指向 +y 时为正。'
          '符号弄错是本工具出错的最常见原因。',
      '转换式中角度是加倍出现的，莫尔圆画的正是这一点——同样的关系，只是用几何表示。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  108: ToolHelp(
    summary: '一点处最大和最小的正应力，以及它们所在的平面。'
        '大多数强度理论都是用主应力表述的，因此这一步通常位于应力分析和安全系数之间。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{1,2} = \frac{\sigma_x+\sigma_y}{2} \pm '
            r'\sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}',
        plain: 'σ1,2 = (σx+σy)/2 ± √[ ((σx−σy)/2)² + τxy² ]',
        caption: '主应力',
      ),
      HelpFormula(
        tex: r'\tan 2\theta_p = \frac{2\tau_{xy}}{\sigma_x-\sigma_y}',
        plain: 'tan2θp = 2·τxy / (σx − σy)',
        caption: '主平面方位',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{\sigma_1-\sigma_2}{2}',
        plain: 'τmax = (σ1 − σ2) / 2',
        caption: '面内最大剪应力',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '主应力，σ1 ≥ σ2', 'MPa'),
      HelpSymbol('θp', '从 x 轴转到 σ1 所在面的角度', '°'),
      HelpSymbol('τmax', '面内最大剪应力', 'MPa'),
    ],
    notes: [
      '主平面上没有剪应力，这正是主平面的定义。',
      '平面应力中第三主应力为零，而它仍可能是三者中最小的。'
          '真正的最大剪应力是三个主应力中 (σmax − σmin)/2，'
          '当 σ1 与 σ2 同号时，它大于面内值。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/icon_stress_element.png',
  ),
  118: ToolHelp(
    summary: '莫尔圆是把应力转换画成几何图形。过该点的每一个截面都对应圆上的一个点，'
        '圆心为平均正应力，半径为面内最大剪应力，因此主应力及其方位一眼即可读出。',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{\sigma_x+\sigma_y}{2}, \quad '
            r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2+\tau_{xy}^2}',
        plain: 'C = (σx+σy)/2，R = √[ ((σx−σy)/2)² + τxy² ]',
        caption: '圆心与半径',
      ),
      HelpFormula(
        tex: r'\sigma_{1,2} = C \pm R, \quad \tau_{\max} = R',
        plain: 'σ1,2 = C ± R，τmax = R',
      ),
    ],
    symbols: [
      HelpSymbol('C', '圆心，即平均正应力', 'MPa'),
      HelpSymbol('R', '圆半径，即面内最大剪应力', 'MPa'),
      HelpSymbol('σx, σy, τxy', '所绘制的应力状态', 'MPa'),
    ],
    notes: [
      '在圆上转一整圈，对应单元体实际转过 180°：圆上的角度是实际角度的两倍。',
      '仅适用于平面应力。完整的三维应力状态要画三个圆，最外面的那个决定最大剪应力。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  116: ToolHelp(
    summary: '把二维应力状态折算成一个可以与屈服强度比较的当量应力。'
        '第四强度理论（von Mises，形状改变比能）是韧性金属的常规选择；'
        '第三强度理论（Tresca，最大剪应力）略偏保守，若干压力容器规范至今仍在使用。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}',
        plain: 'σVM = √(σ1² − σ1·σ2 + σ2²)',
        caption: 'von Mises，平面应力',
      ),
      HelpFormula(
        tex: r'\sigma_{Tresca} = |\sigma_1 - \sigma_2|',
        plain: 'σTresca = |σ1 − σ2|',
        caption: 'Tresca 当量应力',
      ),
      HelpFormula(
        tex: r'n = \frac{S_y}{\sigma_{eq}}',
        plain: 'n = Sy / σeq',
        caption: '抗屈服安全系数',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '主应力', 'MPa'),
      HelpSymbol('σVM', 'von Mises 当量应力', 'MPa'),
      HelpSymbol('Sy', '屈服强度', 'MPa'),
      HelpSymbol('n', '安全系数'),
    ],
    notes: [
      '两种准则都用于预测韧性材料的屈服。脆性材料按最大主应力或莫尔–库仑准则失效，'
          '把 von Mises 用在铸铁上会给出误导性的结果。',
      'Tresca 更保守，最多约保守 15%：两者在单向拉伸时一致，在纯剪时差别最大。',
      '仅适用于静载屈服。交变载荷需要使用疲劳准则。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 5',
      'Hibbeler, Mechanics of Materials, ch. 10',
    ],
  ),
  119: ToolHelp(
    summary: '用修正 Goodman 准则计算承受非零平均应力的交变载荷零件的安全系数。'
        '平均拉应力会使疲劳比单看交变分量时更为不利，Goodman 是考虑这一影响的'
        '标准且略偏保守的方法。',
    formulas: [
      HelpFormula(
        tex: r'\frac{\sigma_a}{S_e} + \frac{\sigma_m}{S_{ut}} = \frac{1}{n}',
        plain: 'σa/Se + σm/Sut = 1/n',
        caption: '修正 Goodman 直线',
      ),
      HelpFormula(
        tex: r'\sigma_a = \frac{\sigma_{\max}-\sigma_{\min}}{2}, \quad '
            r'\sigma_m = \frac{\sigma_{\max}+\sigma_{\min}}{2}',
        plain: 'σa = (σmax − σmin)/2，σm = (σmax + σmin)/2',
        caption: '交变分量与平均分量',
      ),
    ],
    symbols: [
      HelpSymbol('σa', '交变应力幅', 'MPa'),
      HelpSymbol('σm', '平均应力', 'MPa'),
      HelpSymbol('Se', '修正后的持久极限', 'MPa'),
      HelpSymbol('Sut', '抗拉强度', 'MPa'),
      HelpSymbol('n', '抗疲劳安全系数'),
    ],
    notes: [
      'Se 留空时取 0.5·Sut，这是钢的常用初估值。它尚未修正：'
          '实际设计还要乘以表面、尺寸、载荷、温度和可靠性等 Marin 系数，通常会再降低一半左右。',
      '有色金属和铝没有真正的持久极限，其强度随循环次数持续下降，'
          '因此需要按有限寿命计算而非本式。',
      '平均压应力的损伤机理不同。把 Goodman 用于负的 σm 会保守到失真，'
          '此时应取 σm = 0。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 6',
      'Norton, Machine Design, ch. 6',
    ],
  ),
  112: ToolHelp(
    summary: '杆件的自由热膨胀，以及当膨胀被约束时产生的应力。'
        '完全约束的构件所产生的应力只取决于材料和温差，而与长度和截面积无关，'
        '这正是长管道需要膨胀弯而不是更厚的壁的原因。',
    formulas: [
      HelpFormula(
        tex: r'\delta_T = \alpha \, \Delta T \, L',
        plain: 'δT = α · ΔT · L',
        caption: '自由膨胀量',
      ),
      HelpFormula(
        tex: r'\sigma_T = -E \alpha \, \Delta T',
        plain: 'σT = −E · α · ΔT',
        caption: '完全约束时的应力',
      ),
    ],
    symbols: [
      HelpSymbol('δT', '自由长度变化', 'mm'),
      HelpSymbol('α', '线膨胀系数', '1/°C'),
      HelpSymbol('ΔT', '温度变化', '°C'),
      HelpSymbol('L', '原始长度', 'mm'),
      HelpSymbol('σT', '热应力，受热时为压应力', 'MPa'),
    ],
    notes: [
      '约束应力与 L 和 A 无关。把构件做粗并不能降低它，只有允许其移动或减小 ΔT 才行。',
      '完全约束是最不利情况。部分约束时应力介于零与该值之间，与被限制的位移比例相关。',
      'α 随温度变化；温度范围较大时应取区间平均值，而不是室温值。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
  ),
  111: ToolHelp(
    summary: '细长压杆丧失稳定并侧向弯曲时的轴向载荷。屈曲是刚度失效而非强度失效：'
        '临界载荷取决于 E 和 I，几乎与材料强度无关。'
        '长压杆可能在远低于屈服载荷的水平上就屈曲。',
    formulas: [
      HelpFormula(
        tex: r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}',
        plain: 'Pcr = π²·E·I / (K·L)²',
        caption: '欧拉临界载荷',
      ),
      HelpFormula(
        tex: r'\sigma_{cr} = \frac{P_{cr}}{A}, \quad '
            r'\lambda = \frac{KL}{r}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'σcr = Pcr / A，λ = K·L / r，r = √(I/A)',
        caption: '临界应力与长细比',
      ),
    ],
    symbols: [
      HelpSymbol('Pcr', '临界（欧拉）屈曲载荷', 'N'),
      HelpSymbol('E', '弹性模量', 'MPa'),
      HelpSymbol('I', '最小惯性矩', 'mm⁴'),
      HelpSymbol('K', '计算长度系数，由杆端约束决定'),
      HelpSymbol('L', '无支撑长度', 'mm'),
      HelpSymbol('λ', '长细比'),
    ],
    notes: [
      '应取截面最小的 I：压杆总是绕最弱的轴屈曲，而不管你原本预期它往哪边弯。',
      '理论 K 值：两端铰支 1.0，两端固定 0.5，一端固定一端铰支 0.7，一端固定一端自由 2.0。'
          '设计规范取值大于理论值，因为实际杆端从来不是理想固定。',
      '欧拉公式只适用于细长杆。当 σcr 超过屈服强度的约一半时进入非弹性屈曲，'
          '应改用 Johnson 抛物线公式或规范中的柱子曲线。',
      '假定杆件绝对平直且载荷严格居中。实际的初弯曲和偏心会降低承载力，'
          '规范中的安全系数正是为此而设。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 13',
      'AISC Steel Construction Manual, ch. E',
    ],
    diagram: 'images/buckling/icon_buckling_pinned_pinned.png',
  ),
  120: ToolHelp(
    summary: '螺栓或铆钉搭接接头在板件和紧固件上的三种失效方式：'
        '螺栓被剪断、板件被螺栓挤压压溃、以及板件沿边缘被撕脱。'
        '三者同时校核，因为接头的承载力取决于其中最弱的一种。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{P}{n\,m\,\frac{\pi d^2}{4}}',
        plain: 'τ = P / (n·m·π·d²/4)',
        caption: '螺栓剪切；m = 1 为单剪，2 为双剪',
      ),
      HelpFormula(
        tex: r'\sigma_b = \frac{P}{n\,d\,t}',
        plain: 'σb = P / (n·d·t)',
        caption: '按投影面积计算的挤压应力',
      ),
      HelpFormula(
        tex: r'\tau_{to} = \frac{P}{2n\left(e-\frac{d}{2}\right)t}',
        plain: 'τto = P / [2·n·(e − d/2)·t]',
        caption: '沿两个剪切面撕脱至边缘',
      ),
    ],
    symbols: [
      HelpSymbol('P', '接头承受的载荷', 'N'),
      HelpSymbol('n', '紧固件数量'),
      HelpSymbol('m', '每个紧固件的剪切面数：1 或 2'),
      HelpSymbol('d', '紧固件直径', 'mm'),
      HelpSymbol('t', '最薄的连接板厚', 'mm'),
      HelpSymbol('e', '端距，孔心到自由边的距离', 'mm'),
    ],
    notes: [
      '这是承压型接头：载荷由紧固件挤压孔壁传递，而不是靠摩擦。'
          '摩擦型（抗滑移）接头按预紧力和摩擦设计，本组数值并不控制其承载力。',
      '假定载荷在各紧固件间均分。对短而紧凑的螺栓群这是合理的；'
          '对一长排螺栓则偏乐观，两端的紧固件受力更大。',
      '板件净截面的拉断是第四种失效方式，本工具不作校核——'
          '应扣除孔面积后单独验算。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'AISC Steel Construction Manual, ch. J3',
    ],
  ),
  121: ToolHelp(
    summary: '把作用于同一点的轴向、弯曲和扭转载荷合成为一个正应力和一个剪应力。'
        '只要保持线弹性，叠加原理即成立，所得的这一对应力正是强度理论所需要的输入。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A} + \frac{Mc}{I}',
        plain: 'σ = P/A + M·c/I',
        caption: '正应力：轴向加弯曲',
      ),
      HelpFormula(
        tex: r'\tau = \frac{Tr}{J}',
        plain: 'τ = T·r / J',
        caption: '扭转引起的剪应力',
      ),
    ],
    symbols: [
      HelpSymbol('P', '轴向力，受拉为正', 'N'),
      HelpSymbol('A', '横截面积', 'mm²'),
      HelpSymbol('M', '弯矩', 'N·mm'),
      HelpSymbol('c', '中性轴到所求点的距离', 'mm'),
      HelpSymbol('I', '绕弯曲轴的惯性矩', 'mm⁴'),
      HelpSymbol('T', '扭矩', 'N·mm'),
      HelpSymbol('r', '所求点的半径', 'mm'),
      HelpSymbol('J', '极惯性矩', 'mm⁴'),
    ],
    notes: [
      '叠加需要线弹性和小变形。细长构件受压时挠度本身还会产生附加弯矩（P–δ 效应），'
          '本工具不予考虑。',
      '弯曲引起的横向剪应力是另一回事，它在中性轴处最大，而那里弯曲应力为零。'
          '两个位置都要校核，不能只看最外层纤维。',
      '与 mm 和 MPa 配套时，弯矩应取 N·mm。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
  ),

  102: ToolHelp(
    summary: '各种标准截面绕形心轴的惯性矩。I 是决定截面抗弯刚度以及在给定弯矩下'
        '应力大小的几何量——工字钢之所以高效、扁钢之所以不行，原因都在于它。',
    formulas: [
      HelpFormula(
        tex: r'I_x = \frac{bh^3}{12}, \quad I_y = \frac{hb^3}{12}',
        plain: 'Ix = b·h³/12，Iy = h·b³/12',
        caption: '矩形，绕其形心轴',
      ),
      HelpFormula(
        tex: r'I = \frac{\pi d^4}{64}',
        plain: 'I = π·d⁴/64',
        caption: '实心圆',
      ),
      HelpFormula(
        tex: r'I = I_c + Ad^2',
        plain: 'I = Ic + A·d²',
        caption: '平行移轴定理，用于换算到另一根轴',
      ),
    ],
    symbols: [
      HelpSymbol('I', '惯性矩', 'mm⁴'),
      HelpSymbol('b, h', '宽度与高度', 'mm'),
      HelpSymbol('A', '面积', 'mm²'),
      HelpSymbol('d', '两平行轴之间的距离', 'mm'),
    ],
    notes: [
      '高度项是三次方，因此增加高度比增加宽度更能提高刚度：h 加倍使 Ix 变为八倍，'
          'b 加倍只变为两倍。',
      '平行移轴定理只能在形心轴与其平行轴之间换算。两根都不过形心的轴之间换算时，'
          '必须先经过形心。',
      '这里是面积矩，单位 mm⁴，不是动力学中单位为 kg·m² 的转动惯量。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'Gere & Goodno, Mechanics of Materials, ch. 12',
    ],
    diagram: 'images/cross_section/icon_cs_rectangle.png',
  ),
  117: ToolHelp(
    summary: '截面的形心、面积、惯性矩，以及由它们导出的截面模量和回转半径。'
        '这些是每一项梁和柱计算都要用到的量，一并算出可以保证它们彼此一致。',
    formulas: [
      HelpFormula(
        tex: r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'ȳ = Σ(Ai·ȳi) / Σ Ai',
        caption: '组合截面的形心',
      ),
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c，r = √(I / A)',
        caption: '截面模量与回转半径',
      ),
    ],
    symbols: [
      HelpSymbol('ȳ', '自参考边算起的形心位置', 'mm'),
      HelpSymbol('I', '绕形心轴的惯性矩', 'mm⁴'),
      HelpSymbol('S', '截面模量', 'mm³'),
      HelpSymbol('c', '形心到最外层纤维的距离', 'mm'),
      HelpSymbol('r', '回转半径', 'mm'),
    ],
    notes: [
      '截面模量用于按强度选梁（σ = M/S）；回转半径用于按稳定性选柱（λ = KL/r）。',
      '对于不关于弯曲轴对称的截面，上下两侧的 c 不同，因而有两个截面模量，'
          '取较小的那个控制设计。',
      '由裸尺寸算得的特性不含轧制圆角和焊缝金属，因此比型钢的公布值低几个百分点。'
          '若截面属于标准型钢，请使用标准截面库。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'AISC Steel Construction Manual, Part 1',
    ],
  ),
  104: ToolHelp(
    summary: '梁截面上任意高度处的弯曲应力。应力从中性轴处的零线性增大到最外层纤维处的最大值，'
        '因此靠近中性轴的材料几乎不承担载荷，这也是高效截面把面积尽量布置在远离中性轴处的原因。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{My}{I}',
        plain: 'σ = M·y / I',
        caption: '距中性轴 y 处的弯曲应力',
      ),
      HelpFormula(
        tex: r'\sigma_{\max} = \frac{Mc}{I} = \frac{M}{S}',
        plain: 'σmax = M·c / I = M / S',
        caption: '最外层纤维处',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '弯曲应力，受拉为正', 'MPa'),
      HelpSymbol('M', '该截面的弯矩', 'N·mm'),
      HelpSymbol('y', '到中性轴的距离', 'mm'),
      HelpSymbol('I', '绕弯曲轴的惯性矩', 'mm⁴'),
      HelpSymbol('c', '到最外层纤维的距离', 'mm'),
    ],
    notes: [
      '欧拉–伯努利理论：平截面保持平面，材料线弹性，梁为等截面直梁。',
      '只有均质截面的纯弯曲，中性轴才通过形心。轴向力会使其偏移，'
          '组合材料截面需要用换算截面法分析。',
      '绕非主轴弯曲属于斜弯曲，本单轴公式不适用。',
      '与 mm 和 MPa 配套时，M 应取 N·mm。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 6',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
    diagram: 'images/icon_beam_bending.png',
  ),
  113: ToolHelp(
    summary: '梁截面上的横向剪应力。它在中性轴处最大——而那里弯曲应力恰好为零——'
        '因此两者必须在不同高度分别校核。它对短而高的梁以及薄腹板最为重要，'
        '这类情况下剪切可能比弯曲更起控制作用。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{VQ}{It}',
        plain: 'τ = V·Q / (I·t)',
        caption: '取 Q 的那一高度处的剪应力',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{3V}{2A} \;\text{(rectangle)}, \quad '
            r'\frac{4V}{3A} \;\text{(circle)}',
        plain: 'τmax = 3V/(2A) 矩形，4V/(3A) 圆形',
        caption: '常见实心截面的峰值',
      ),
    ],
    symbols: [
      HelpSymbol('τ', '横向剪应力', 'MPa'),
      HelpSymbol('V', '该截面的剪力', 'N'),
      HelpSymbol('Q', '所切位置以外部分面积的静矩', 'mm³'),
      HelpSymbol('I', '整个截面的惯性矩', 'mm⁴'),
      HelpSymbol('t', '所切位置处的截面宽度', 'mm'),
    ],
    notes: [
      'Q 只取所校核高度一侧的面积对中性轴的静矩。它在中性轴处最大，在最外层纤维处为零。',
      '公式假定剪应力沿宽度 t 均匀分布。对窄腹板这很接近实际，'
          '对宽翼缘则不然，实际分布沿宽度是变化的。',
      '对工字梁，用 V 除以腹板面积的常用简化与精确值相差仅几个百分点，设计规范正是这样做的。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 7',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
  ),
  105: ToolHelp(
    summary: '悬臂梁在标准载荷工况下的挠度和转角，取自经典闭式解。'
        '可用于快速校核刚度，也可用叠加法组合成更复杂的受载情况。',
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
        caption: '全跨均布载荷 w',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '挠度', 'mm'),
      HelpSymbol('θ', '转角', 'rad'),
      HelpSymbol('P', '集中力', 'N'),
      HelpSymbol('w', '分布载荷', 'N/mm'),
      HelpSymbol('L', '自固定端起的跨度', 'mm'),
      HelpSymbol('E·I', '抗弯刚度', 'N·mm²'),
    ],
    notes: [
      '挠度与 L³ 或 L⁴ 成正比。自由端受力的悬臂梁跨度加倍，柔度变为八倍——长度的影响压倒一切。',
      '小挠度欧拉–伯努利理论，忽略剪切变形。'
          '对粗短悬臂（L/d 小于约 10）应补充剪切项。',
      '载荷可以叠加：多个载荷同时作用时，把各工况的挠度相加即可。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/cantilever_beam/icon_cantilever_beam.png',
  ),
  106: ToolHelp(
    summary: '简支梁在标准载荷工况下的挠度和转角，与手册所列的闭式解相同。'
        '可用于快速校核跨度，也可用叠加法拼出更复杂的受载情况。',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{48EI}',
        plain: 'δmax = P·L³/(48·E·I)',
        caption: '跨中集中力',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{5wL^4}{384EI}',
        plain: 'δmax = 5·w·L⁴/(384·E·I)',
        caption: '全跨均布载荷',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '挠度', 'mm'),
      HelpSymbol('P', '集中力', 'N'),
      HelpSymbol('w', '分布载荷', 'N/mm'),
      HelpSymbol('L', '支座间跨度', 'mm'),
      HelpSymbol('E·I', '抗弯刚度', 'N·mm²'),
    ],
    notes: [
      '集中力偏离跨中时，最大挠度既不在力作用点，也不在跨中——'
          '但跨中值与最大值相差约 2.5% 以内，手册因此直接给出跨中值。',
      '小挠度理论，一端铰支一端滚动支承，因此没有轴向约束。'
          '两端受轴向约束的梁在挠曲时会变刚，本式会高估其位移。',
      '正常使用极限通常以跨度的比例控制（楼面活载常用 L/360），而不是以应力控制。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  401: ToolHelp(
    summary: '简支梁在集中力、全跨均布载荷或两者共同作用下的支座反力、剪力和弯矩。'
        '剪力图和弯矩图告诉你该在哪个截面校核，以及校核时该用多大的 M。',
    formulas: [
      HelpFormula(
        tex: r'\sum F_y = 0, \quad \sum M = 0',
        plain: 'ΣFy = 0，ΣM = 0',
        caption: '静力平衡，由此确定两个支反力',
      ),
      HelpFormula(
        tex: r'V(x) = R_A - \int_0^x w\,dx, \quad M(x) = \int_0^x V\,dx',
        plain: 'V(x) = RA − ∫w dx，M(x) = ∫V dx',
        caption: '沿跨度的剪力与弯矩',
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
      HelpSymbol('M', '弯矩', 'N·mm'),
      HelpSymbol('w', '均布载荷', 'N/mm'),
      HelpSymbol('L', '跨度', 'mm'),
    ],
    notes: [
      '仅限静定情况：一端铰支、一端滚动支承。'
          '增加第三个支座或固定端后即为超静定，除平衡条件外还需变形协调条件。',
      '弯矩在剪力过零处取极值。那才是应当设计的截面，而对偏心载荷它并不在跨中。',
      '不计自重，除非把它计入分布载荷中。',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 4',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  400: ToolHelp(
    summary: '把平面内的共点力合成为一个合力，给出其大小和方向。'
        '这是几乎所有静力学问题的第一步：用一个等效的力取代一组力。',
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
        caption: '大小与方向',
      ),
    ],
    symbols: [
      HelpSymbol('F', '各力的大小', 'N'),
      HelpSymbol('θ', '各力的方向，自 +x 轴量起', '°'),
      HelpSymbol('R', '合力大小', 'N'),
      HelpSymbol('θR', '合力方向', '°'),
    ],
    notes: [
      '仅限共点力，即所有作用线交于一点。不共点的力还会产生力偶，'
          '若把它们简化为作用在错误位置上的单个力，这个力偶就丢失了。',
      '使用 atan2 而非 arctan，以保证象限正确；单纯的 arctan 无法区分 30° 与 210°。',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 2',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 2',
    ],
  ),
  402: ToolHelp(
    summary: '由矩形、圆和三角形（可含孔洞）组成的图形的形心。'
        '形心是面积静矩为零的位置，也是一切弯曲计算所参照的轴——'
        '形心求错，其后的每一个应力都会错。',
    formulas: [
      HelpFormula(
        tex: r'\bar{x} = \frac{\sum A_i \bar{x}_i}{\sum A_i}, \quad '
            r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'x̄ = Σ(Ai·x̄i)/ΣAi，ȳ = Σ(Ai·ȳi)/ΣAi',
        caption: '按面积加权的平均值',
      ),
    ],
    symbols: [
      HelpSymbol('Ai', '各部分的面积，孔洞取负', 'mm²'),
      HelpSymbol('x̄i, ȳi', '各部分自身的形心', 'mm'),
      HelpSymbol('x̄, ȳ', '整体的形心', 'mm'),
    ],
    notes: [
      '把孔洞当作带有自身形心的负面积处理，公式即可自动照顾到它，无需特殊处理。',
      '形心一定落在任何一条对称轴上，据此往往可以直接写出其中一个坐标而无需计算。',
      '只有密度均匀时，形心才与质心重合。',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 9',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 5',
    ],
  ),
  403: ToolHelp(
    summary: '用节点法求解平面铰接桁架：每个节点都是处于平衡的共点力系，'
        '逐个节点求解即可得到全部杆件内力。正值为受拉，负值为受压。',
    formulas: [
      HelpFormula(
        tex: r'\sum F_x = 0, \quad \sum F_y = 0 \;\text{at every joint}',
        plain: '每个节点满足 ΣFx = 0 和 ΣFy = 0',
        caption: '平衡条件，每个节点两个方程',
      ),
      HelpFormula(
        tex: r'm + r = 2j',
        plain: 'm + r = 2·j',
        caption: '静定性判别',
      ),
    ],
    symbols: [
      HelpSymbol('m', '杆件数'),
      HelpSymbol('r', '支座反力数'),
      HelpSymbol('j', '节点数'),
    ],
    notes: [
      '假定为无摩擦铰接且载荷只作用在节点上，因此每根杆只承受轴力。'
          '作用在杆中部的载荷还会使其弯曲，这超出本模型的范围。',
      'm + r < 2j 为机构，无法承载；m + r > 2j 为超静定，除平衡条件外还需杆件刚度。',
      '静定桁架仍可能因几何布置不当而不稳定，例如三个支反力共线。'
          '数目判别是必要条件而非充分条件。',
      '受压杆还必须校核屈曲，本工具不作此项。',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 3',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 6',
    ],
  ),
  200: ToolHelp(
    summary: '各向同性材料的三维广义胡克定律。一个方向上的应力会通过泊松比在'
        '另外两个方向上产生应变，因此六个分量是相互耦合的，不能逐个孤立处理。',
    formulas: [
      HelpFormula(
        tex: r'\varepsilon_x = \frac{1}{E}\left[\sigma_x - '
            r'\nu(\sigma_y+\sigma_z)\right]',
        plain: 'εx = [σx − ν(σy + σz)] / E',
        caption: '正应变，三式之一',
      ),
      HelpFormula(
        tex: r'\gamma_{xy} = \frac{\tau_{xy}}{G}, \quad '
            r'G = \frac{E}{2(1+\nu)}',
        plain: 'γxy = τxy / G，G = E / [2(1 + ν)]',
        caption: '剪应变，以及模量关系',
      ),
    ],
    symbols: [
      HelpSymbol('ε', '正应变'),
      HelpSymbol('γ', '工程剪应变'),
      HelpSymbol('σ, τ', '正应力与剪应力', 'MPa'),
      HelpSymbol('E', '弹性模量', 'MPa'),
      HelpSymbol('ν', '泊松比'),
      HelpSymbol('G', '剪切模量', 'MPa'),
    ],
    notes: [
      '适用于各向同性、均质、线弹性材料。复合材料、织构明显的轧制板材和木材都不属于此类。',
      '各向同性材料的 E、G、ν 中只有两个独立，第三个由前两个决定。'
          '三个都输入且彼此不自洽，会悄悄给出错误结果。',
      '热力学稳定性要求 ν 介于 −1 与 0.5 之间。实际金属接近 0.3，'
          '而 0.5 表示不可压缩，橡胶接近这一数值。',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 3',
    ],
  ),
  201: ToolHelp(
    summary: '在完整的三维应力状态与其对应的应变状态之间双向换算。'
        '由应变求应力的形式正是有限元后处理所需要的：网格给出的是应变，'
        '而强度准则要用的是应力。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_x = \frac{E}{(1+\nu)(1-2\nu)}\left[(1-\nu)'
            r'\varepsilon_x + \nu(\varepsilon_y+\varepsilon_z)\right]',
        plain: 'σx = E/[(1+ν)(1−2ν)] · [(1−ν)εx + ν(εy + εz)]',
        caption: '由应变求应力',
      ),
      HelpFormula(
        tex: r'\tau_{xy} = G\gamma_{xy}',
        plain: 'τxy = G · γxy',
        caption: '剪切项保持解耦',
      ),
    ],
    symbols: [
      HelpSymbol('σ, τ', '正应力与剪应力', 'MPa'),
      HelpSymbol('ε, γ', '正应变与工程剪应变'),
      HelpSymbol('E', '弹性模量', 'MPa'),
      HelpSymbol('ν', '泊松比'),
    ],
    notes: [
      '由应变求应力的形式在 ν 趋近 0.5 时发散：分母中的 (1 − 2ν) 趋于零，'
          '因为不可压缩材料在给定应变下并无唯一的静水压力。'
          '近似不可压缩的材料需要采用混合列式。',
      '工程剪应变 γ 是张量剪应变的两倍。混用这两种约定会造成难以察觉的二倍误差。',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Sadd, Elasticity: Theory, Applications and Numerics, ch. 4',
    ],
  ),
  305: ToolHelp(
    summary: '由纤维和基体的性能估算单向层的刚度与密度。沿纤维方向两相变形一致，'
        '刚度按体积加权平均；垂直纤维方向两相共同承载，平均的是柔度，'
        '这正是横向刚度低得多的原因。',
    formulas: [
      HelpFormula(
        tex: r'E_1 = E_f V_f + E_m(1-V_f)',
        plain: 'E1 = Ef·Vf + Em·(1 − Vf)',
        caption: '纵向——混合律',
      ),
      HelpFormula(
        tex: r'\frac{1}{E_2} = \frac{V_f}{E_f} + \frac{1-V_f}{E_m}',
        plain: '1/E2 = Vf/Ef + (1 − Vf)/Em',
        caption: '横向——反混合律',
      ),
      HelpFormula(
        tex: r'\nu_{12} = \nu_f V_f + \nu_m(1-V_f)',
        plain: 'ν12 = νf·Vf + νm·(1 − Vf)',
        caption: '主泊松比',
      ),
    ],
    symbols: [
      HelpSymbol('E1', '沿纤维方向的刚度', 'MPa'),
      HelpSymbol('E2', '垂直纤维方向的刚度', 'MPa'),
      HelpSymbol('Vf', '纤维体积分数'),
      HelpSymbol('Ef, Em', '纤维与基体的模量', 'MPa'),
    ],
    notes: [
      'E1 相当可靠；而横向的反混合律偏乐观，实测值通常低于它。'
          '横向刚度重要时，Halpin–Tsai 是标准的改进方法。',
      '这里用的是体积分数而非质量分数。供应商常给出质量分数，'
          '使用前请用两者的密度换算。',
      '成型良好的层合板 Vf 上限约 0.65；再高就没有足够的基体浸润纤维了。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 3',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 3',
    ],
    diagram: 'images/lamina.png',
  ),
  301: ToolHelp(
    summary: '正交异性单层的四个独立工程弹性常数——两个模量、一个剪切模量和一个泊松比——'
        '以及由它们组成的柔度矩阵。所有层合板计算都从这里开始。',
    formulas: [
      HelpFormula(
        tex: r'\frac{\nu_{12}}{E_1} = \frac{\nu_{21}}{E_2}',
        plain: 'ν12 / E1 = ν21 / E2',
        caption: '互等关系，它保证柔度矩阵对称',
      ),
      HelpFormula(
        tex: r'Q_{11} = \frac{E_1}{1-\nu_{12}\nu_{21}}, \quad '
            r'Q_{22} = \frac{E_2}{1-\nu_{12}\nu_{21}}, \quad Q_{66} = G_{12}',
        plain: 'Q11 = E1/(1 − ν12·ν21)，Q22 = E2/(1 − ν12·ν21)，Q66 = G12',
        caption: '折减刚度',
      ),
    ],
    symbols: [
      HelpSymbol('E1, E2', '纵向与横向模量', 'MPa'),
      HelpSymbol('G12', '面内剪切模量', 'MPa'),
      HelpSymbol('ν12', '主泊松比'),
      HelpSymbol('Q', '折减刚度矩阵各项', 'MPa'),
    ],
    notes: [
      '平面应力下只有四个常数独立，ν21 由互等关系确定。'
          '若另行输入实测的、与之不符的 ν21，会使矩阵不对称而失去物理意义。',
      'ν12 表示沿方向 1 加载所引起的方向 2 的收缩。'
          '下标顺序是复合材料中最常见的混淆之处，部分教材的约定恰好相反。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 4',
    ],
    diagram: 'images/lamina.png',
  ),
  300: ToolHelp(
    summary: '单层在材料主轴或任意转角坐标系下的应力与应变。'
        '由于单层沿纤维方向远比横向刚硬，转角带来的不只是数值的旋转：'
        '偏轴铺层会把正应力与剪应变耦合起来。',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}\sigma_1\\\sigma_2\\\tau_{12}\end{bmatrix} = '
            r'[Q]\begin{bmatrix}\varepsilon_1\\\varepsilon_2\\'
            r'\gamma_{12}\end{bmatrix}',
        plain: '{σ1, σ2, τ12} = [Q] · {ε1, ε2, γ12}',
        caption: '材料主轴坐标系下',
      ),
      HelpFormula(
        tex: r'[\bar{Q}] = [T]^{-1}[Q][T]^{-T}',
        plain: '[Q̄] = [T]⁻¹ [Q] [T]⁻ᵀ',
        caption: '转换到层合板坐标系',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '沿纤维与垂直纤维方向的应力', 'MPa'),
      HelpSymbol('τ12', '面内剪应力', 'MPa'),
      HelpSymbol('[Q]', '折减刚度矩阵', 'MPa'),
      HelpSymbol('θ', '相对层合板 x 轴的铺层角', '°'),
    ],
    notes: [
      '单层按平面应力处理：忽略厚度方向应力。'
          '这在薄层合板内部是合理的，在自由边缘则不成立，而分层正是从那里开始的。',
      'θ 只要不是 0° 或 90°，转换后的矩阵就会出现非零的 Q̄16 和 Q̄26，'
          '即剪切–拉伸耦合。这是真实存在的效应，不是数值假象。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 5',
    ],
    diagram: 'images/lamina.png',
  ),
  302: ToolHelp(
    summary: '经典层合板理论：把各铺层组装成 A、B、D 矩阵，'
        '把面内力和弯矩与中面应变和曲率联系起来。'
        '正是它把一叠铺层变成一种性能可预测的结构材料。',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}N\\M\end{bmatrix} = '
            r'\begin{bmatrix}A & B\\B & D\end{bmatrix}'
            r'\begin{bmatrix}\varepsilon^0\\\kappa\end{bmatrix}',
        plain: '{N, M} = [[A, B], [B, D]] · {ε⁰, κ}',
        caption: '层合板本构关系',
      ),
      HelpFormula(
        tex: r'A_{ij}=\sum \bar{Q}_{ij}(z_k-z_{k-1}), \quad '
            r'B_{ij}=\tfrac{1}{2}\sum \bar{Q}_{ij}(z_k^2-z_{k-1}^2), \quad '
            r'D_{ij}=\tfrac{1}{3}\sum \bar{Q}_{ij}(z_k^3-z_{k-1}^3)',
        plain: 'Aij = ΣQ̄ij·(zk − zk−1)；Bij = ½ΣQ̄ij·(zk² − zk−1²)；'
            'Dij = ⅓ΣQ̄ij·(zk³ − zk−1³)',
        caption: '拉伸、耦合与弯曲刚度',
      ),
    ],
    symbols: [
      HelpSymbol('N', '单位宽度上的面内力', 'N/mm'),
      HelpSymbol('M', '单位宽度上的弯矩', 'N·mm/mm'),
      HelpSymbol('ε⁰', '中面应变'),
      HelpSymbol('κ', '曲率', '1/mm'),
      HelpSymbol('z', '铺层界面相对中面的高度', 'mm'),
    ],
    notes: [
      '当且仅当铺层关于中面对称时 B 才为零。非零的 B 会把拉伸与弯曲耦合起来，'
          '零件在固化冷却时就会翘曲——这正是实际层合板几乎都做成对称铺层的原因。',
      '经典层合板理论忽略横向剪切，因此会高估厚层合板以及软芯夹层板的刚度。',
      '不含固化产生的残余热应力，而它可能占首层失效载荷的相当大一部分。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  303: ToolHelp(
    summary: '层合板的等效面内工程常数——即把整叠铺层当作均质薄板测试时所得到的模量。'
        '便于与金属作对比，也便于把层合板输入只接受单一材料的分析程序。',
    formulas: [
      HelpFormula(
        tex: r'E_x = \frac{1}{h\,a_{11}}, \quad E_y = \frac{1}{h\,a_{22}}, '
            r'\quad G_{xy} = \frac{1}{h\,a_{66}}',
        plain: 'Ex = 1/(h·a11)，Ey = 1/(h·a22)，Gxy = 1/(h·a66)',
        caption: '由拉伸刚度的逆 [a] = [A]⁻¹ 求得',
      ),
      HelpFormula(
        tex: r'\nu_{xy} = -\frac{a_{12}}{a_{11}}',
        plain: 'νxy = −a12 / a11',
      ),
    ],
    symbols: [
      HelpSymbol('Ex, Ey', '等效面内模量', 'MPa'),
      HelpSymbol('Gxy', '等效面内剪切模量', 'MPa'),
      HelpSymbol('h', '层合板总厚度', 'mm'),
      HelpSymbol('[a]', 'A 矩阵的逆', 'mm/N'),
    ],
    notes: [
      '这些常数只描述面内行为。弯曲刚度来自 D，'
          '同样的铺层换一个顺序，A 不变而 D 会变——铺层顺序对弯曲有影响，对拉伸没有。',
      '只有对称层合板才有意义。B 矩阵非零时，铺层根本不像一块均质薄板那样表现。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  304: ToolHelp(
    summary: '层合板的三维等效性能，包含经典层合板理论所略去的厚度方向各项。'
        '在零件较厚、存在面外载荷，或需要建立实体有限元模型时需要它们。',
    formulas: [
      HelpFormula(
        tex: r'[C] = [S]^{-1}',
        plain: '[C] = [S]⁻¹',
        caption: '刚度是组装后柔度矩阵的逆',
      ),
    ],
    symbols: [
      HelpSymbol('[C]', '6×6 刚度矩阵', 'MPa'),
      HelpSymbol('[S]', '6×6 柔度矩阵', '1/MPa'),
      HelpSymbol('E3', '厚度方向模量', 'MPa'),
      HelpSymbol('G13, G23', '横向剪切模量', 'MPa'),
    ],
    notes: [
      '厚度方向的性能由基体控制，数值很低，往往比 E1 低两个数量级。'
          '这正是复合材料以分层方式而非屈服方式失效的原因。',
      '三维等效性能把层合板抹平成一块均质各向异性实体。'
          '这对整体刚度是合适的，但对自由边缘的层间应力毫无用处，那需要逐层模型。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Herakovich, Mechanics of Fibrous Composites, ch. 3',
    ],
    diagram: 'images/laminate.png',
  ),
  306: ToolHelp(
    summary: '单向层在复合应力下的首层失效准则。'
        'Tsai–Hill 和 Tsai–Wu 是相互作用的二次型准则；'
        '最大应力和最大应变准则则逐个分量校核，并能指出是哪种模式失效。',
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
        caption: 'Tsai–Wu，可区分拉伸与压缩',
      ),
    ],
    symbols: [
      HelpSymbol('X', '纵向强度', 'MPa'),
      HelpSymbol('Y', '横向强度', 'MPa'),
      HelpSymbol('S', '面内剪切强度', 'MPa'),
      HelpSymbol('σ1, σ2, τ12', '材料主轴下的单层应力', 'MPa'),
    ],
    notes: [
      '这些准则预测的是首层失效，而不是层合板的最终破坏。'
          '首层开裂后层合板通常还能继续承受相当大的载荷，'
          '求真正的极限承载力需要渐进失效分析。',
      '应根据应力的正负分别取拉伸或压缩强度。Tsai–Hill 的基本形式不会自动这样做。',
      'Tsai–Wu 需要相互作用项 F12，而它很难测定；'
          'F12 = −½√(F11·F22) 是常用且合理的默认取值。',
      '这些准则都不说明单层是"怎样"失效的。最大应力准则能说明，'
          '因此仍值得同时计算。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Tsai & Wu, "A General Theory of Strength for Anisotropic Materials", '
          'J. Composite Materials, 1971',
    ],
    diagram: 'images/lamina.png',
  ),

  701: ToolHelp(
    summary: '圆截面钢丝螺旋压缩弹簧：弹簧指数、计入曲率和直接剪切的 Wahl 修正系数、'
        '刚度以及颤振频率。需要留意的是弹簧指数 C——小于约 4 卷制困难，'
        '大于 12 则容易缠绕和失稳。',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{D}{d}, \quad '
            r'K_W = \frac{4C-1}{4C-4} + \frac{0.615}{C}',
        plain: 'C = D/d，KW = (4C − 1)/(4C − 4) + 0.615/C',
        caption: '弹簧指数与 Wahl 系数',
      ),
      HelpFormula(
        tex: r'\tau = K_W \frac{8FD}{\pi d^3}',
        plain: 'τ = KW · 8·F·D / (π·d³)',
        caption: '修正后的钢丝剪应力',
      ),
      HelpFormula(
        tex: r'k = \frac{Gd^4}{8D^3N_a}',
        plain: 'k = G·d⁴ / (8·D³·Na)',
        caption: '弹簧刚度',
      ),
    ],
    symbols: [
      HelpSymbol('d', '钢丝直径', 'mm'),
      HelpSymbol('D', '中径', 'mm'),
      HelpSymbol('C', '弹簧指数'),
      HelpSymbol('Na', '有效圈数'),
      HelpSymbol('G', '钢丝剪切模量', 'MPa'),
      HelpSymbol('k', '弹簧刚度', 'N/mm'),
    ],
    notes: [
      'D 是中径，即外径减去一个钢丝直径。误用外径会明显高估刚度。',
      '有效圈数少于总圈数：并紧磨平的端部约少两圈，不并紧的端部则几乎不少。',
      '工作频率应远离颤振频率——气门弹簧通常要求相差 15 至 20 倍。'
          '颤振是沿弹簧传播的波，而不是刚体振型。',
      '钢丝强度与直径关系很大：同种合金的细丝比粗丝强得多。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 10',
      'Wahl, Mechanical Springs',
    ],
  ),
  702: ToolHelp(
    summary: '20° 标准齿形渐开线直齿圆柱齿轮副的几何参数——分度圆直径、中心距和传动比——'
        '以及 Lewis 弯曲应力估算和简化的接触应力值。这是初步选型，而非 AGMA 承载能力校核。',
    formulas: [
      HelpFormula(
        tex: r'd = mN, \quad C = \frac{d_1+d_2}{2}, \quad '
            r'i = \frac{N_2}{N_1}',
        plain: 'd = m·N，C = (d1 + d2)/2，i = N2/N1',
        caption: '分度圆直径、中心距、传动比',
      ),
      HelpFormula(
        tex: r'\sigma = \frac{W_t}{b\,m\,Y}',
        plain: 'σ = Wt / (b·m·Y)',
        caption: '齿根 Lewis 弯曲应力',
      ),
    ],
    symbols: [
      HelpSymbol('m', '模数', 'mm'),
      HelpSymbol('N', '齿数'),
      HelpSymbol('d', '分度圆直径', 'mm'),
      HelpSymbol('Wt', '切向齿面力', 'N'),
      HelpSymbol('b', '齿宽', 'mm'),
      HelpSymbol('Y', 'Lewis 齿形系数'),
    ],
    notes: [
      'Lewis 公式把单个轮齿当作静载悬臂梁。它不计齿根圆角处的应力集中、'
          '动载效应、多齿分担载荷和安装误差——而 AGMA 2001 用一系列明确的系数考虑了这些，'
          '真正的承载能力校核也离不开它们。',
      '20° 标准齿形的小齿轮齿数少于 17 会发生根切，再少就需要变位。',
      '接触（赫兹）应力通常控制齿面耐久性，弯曲应力控制轮齿折断。'
          '两者都要校核，它们的失效方式不同。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 13–14',
      'ANSI/AGMA 2001-D04',
    ],
  ),
  703: ToolHelp(
    summary: '在弯曲交变、扭转稳定的复合载荷下，按畸变能理论结合修正 Goodman 准则'
        '求轴的最小直径。这是最常见工况——旋转轴弯曲完全对称循环、扭矩恒定——'
        '的标准轴径计算式。',
    formulas: [
      HelpFormula(
        tex: r'd = \left(\frac{16n}{\pi}\left\{\frac{1}{S_e}\left[4(K_f '
            r'M_a)^2 + 3(K_{fs}T_a)^2\right]^{1/2} + \frac{1}{S_{ut}}'
            r'\left[4(K_f M_m)^2 + 3(K_{fs}T_m)^2\right]^{1/2}\right\}'
            r'\right)^{1/3}',
        plain: 'd = { (16n/π) · [ (1/Se)·√(4(Kf·Ma)² + 3(Kfs·Ta)²) '
            '+ (1/Sut)·√(4(Kf·Mm)² + 3(Kfs·Tm)²) ] }^(1/3)',
        caption: 'DE–Goodman 轴径公式',
      ),
    ],
    symbols: [
      HelpSymbol('Ma, Mm', '交变与平均弯矩', 'N·m'),
      HelpSymbol('Ta, Tm', '交变与平均扭矩', 'N·m'),
      HelpSymbol('Se', '修正后的持久极限', 'MPa'),
      HelpSymbol('Sut', '抗拉强度', 'MPa'),
      HelpSymbol('Kf, Kfs', '疲劳应力集中系数'),
      HelpSymbol('n', '设计系数'),
    ],
    notes: [
      '旋转轴承受不变的横向载荷时，弯曲是完全对称循环：Ma 取全部弯矩，Mm 为零。'
          '恒定驱动产生的扭矩正好相反，只有 Tm。',
      'Kf 和 Kfs 是危险截面处的疲劳系数，通常出现在轴肩圆角、键槽或过盈配合处。'
          '取 1 偏乐观，尖锐轴肩很容易达到 2。',
      '本式只按疲劳强度定尺寸。还应校核挠度、轴承处的转角和临界转速——'
          '通过本校核的轴仍可能无法使用。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'ANSI/ASME B106.1M, Design of Transmission Shafting',
    ],
  ),
  704: ToolHelp(
    summary: '滚动轴承的基本额定寿命：同一批轴承中 90% 能够达到的转数。'
        '指数使寿命对载荷极为敏感——载荷减半，球轴承寿命变为八倍。',
    formulas: [
      HelpFormula(
        tex: r'L_{10} = \left(\frac{C}{P}\right)^{p}',
        plain: 'L10 = (C/P)^p，球轴承 p = 3，滚子轴承 p = 10/3',
        caption: '额定寿命，单位为百万转',
      ),
      HelpFormula(
        tex: r'L_{10h} = \frac{10^6 L_{10}}{60n}',
        plain: 'L10h = 10⁶ · L10 / (60·n)',
        caption: '换算为小时',
      ),
    ],
    symbols: [
      HelpSymbol('C', '基本额定动载荷，取自样本', 'N'),
      HelpSymbol('P', '当量动载荷', 'N'),
      HelpSymbol('n', '转速', 'rpm'),
      HelpSymbol('L10', '额定寿命', '百万转'),
    ],
    notes: [
      'L10 的含义是到该时刻预计已有 10% 失效，而不是轴承能用那么久。'
          '中位寿命约为 L10 的五倍。',
      'P 是当量载荷 P = X·Fr + Y·Fa，用样本系数把径向和轴向分量合成，'
          '在存在轴向力时并不等于径向载荷。',
      '基本额定寿命不考虑润滑、污染和温度。ISO 281 为此引入寿命修正系数 a-ISO，'
          '润滑不良的轴承可能远达不到 L10。',
      'C 必须是动载荷额定值。静载荷额定值 C0 控制静止轴承的压痕，是另一个量。',
    ],
    references: [
      'ISO 281, Rolling bearings — Dynamic load ratings and rating life',
      'Shigley, Mechanical Engineering Design, ch. 11',
    ],
  ),
  705: ToolHelp(
    summary: '开口带传动或滚子链传动的几何参数：传动比、带长以及各轮上的包角。'
        '小带轮的包角决定摩擦型带传动在打滑前所能传递的最大扭矩。',
    formulas: [
      HelpFormula(
        tex: r'i = \frac{D_2}{D_1} = \frac{n_1}{n_2}',
        plain: 'i = D2/D1 = n1/n2',
        caption: '传动比',
      ),
      HelpFormula(
        tex: r'L = 2C + \frac{\pi}{2}(D_1+D_2) + \frac{(D_2-D_1)^2}{4C}',
        plain: 'L = 2C + (π/2)(D1 + D2) + (D2 − D1)²/(4C)',
        caption: '开口带长度',
      ),
      HelpFormula(
        tex: r'\theta_1 = \pi - 2\arcsin\frac{D_2-D_1}{2C}',
        plain: 'θ1 = π − 2·arcsin[(D2 − D1)/(2C)]',
        caption: '小带轮包角',
      ),
    ],
    symbols: [
      HelpSymbol('D1, D2', '小轮与大轮的节圆直径', 'mm'),
      HelpSymbol('C', '中心距', 'mm'),
      HelpSymbol('L', '带长', 'mm'),
      HelpSymbol('θ1', '小带轮包角', 'rad'),
    ],
    notes: [
      '带长表达式是标准近似式，当 C 大于约 (D1 + D2) 时非常接近精确值。',
      '小带轮包角应保持在约 120° 以上。低于此值时，平带或 V 带在达到额定能力前就会打滑，'
          '通常用张紧轮来解决。',
      '滚子链应使用节圆直径，并把链长圆整为偶数个节距——奇数节需要过渡链节，强度较低。',
      '仅为几何计算：带的传递功率能力取决于型号、线速度和制造商样本中的工况系数。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 17',
      'ANSI/ASME B29.1, Precision Power Transmission Roller Chains',
    ],
  ),
  706: ToolHelp(
    summary: '用简化的扭矩–预紧力关系式，求达到目标预紧力所需的拧紧力矩。'
        '真正把接头夹紧的是预紧力，而扭矩只是它的间接量度——而且是很不精确的量度，'
        '因此这个数值需要谨慎对待。',
    formulas: [
      HelpFormula(
        tex: r'T = K F_i d',
        plain: 'T = K · Fi · d',
        caption: '达到目标预紧力所需的力矩',
      ),
      HelpFormula(
        tex: r'F_i \approx 0.75 A_t S_p \;\text{(reused)}, \quad '
            r'0.90 A_t S_p \;\text{(permanent)}',
        plain: 'Fi ≈ 0.75·At·Sp（可重复使用），0.90·At·Sp（永久连接）',
        caption: '常用的预紧力目标值',
      ),
    ],
    symbols: [
      HelpSymbol('T', '拧紧力矩', 'N·m'),
      HelpSymbol('K', '扭矩系数，无镀层钢约 0.20'),
      HelpSymbol('Fi', '目标预紧力', 'N'),
      HelpSymbol('d', '螺栓公称直径', 'mm'),
      HelpSymbol('At', '公称应力面积', 'mm²'),
      HelpSymbol('Sp', '保证应力', 'MPa'),
    ],
    notes: [
      'K 把螺纹摩擦和支承面摩擦合在一起，是本方法最薄弱的环节：'
          '它随镀层、润滑和重复使用而变化，仅靠扭矩控制时预紧力的离散度通常达 ±25–30%。',
      '输入力矩中约 90% 消耗在摩擦上，只有约 10% 转化为拉力。'
          '因此摩擦的微小变化会引起预紧力的很大变化。',
      '预紧力真正重要时，应直接测量——过贴合点后的转角控制、螺栓伸长测量'
          '或指示垫圈——而不要依赖扭矩。',
      '应使用公称应力面积 At，而不是光杆面积。M10 粗牙的 At 为 58 mm²，'
          '而按公称直径计算是 78.5 mm²。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'Bickford, An Introduction to the Design and Behavior of Bolted Joints',
    ],
  ),
  707: ToolHelp(
    summary: '角焊缝焊喉上的剪应力。焊喉是焊缝中最小的截面，因而是破坏面；'
        '设计实践中不论接头如何受载，都按焊喉受剪来校核角焊缝。',
    formulas: [
      HelpFormula(
        tex: r'a = 0.707\,w, \quad \tau = \frac{F}{a L}',
        plain: 'a = 0.707·w，τ = F / (a·L)',
        caption: '焊喉厚度及其上的剪应力',
      ),
    ],
    symbols: [
      HelpSymbol('w', '角焊缝焊脚尺寸', 'mm'),
      HelpSymbol('a', '有效焊喉，等腰角焊缝为 0.707·w', 'mm'),
      HelpSymbol('L', '有效焊缝长度', 'mm'),
      HelpSymbol('F', '焊缝组承受的载荷', 'N'),
    ],
    notes: [
      '把所有角焊缝都按焊喉受剪处理是标准简化。实际上横向受载的角焊缝'
          '比纵向的强约 50%，规范允许用方向强度系数计入这一点。',
      '0.707 系数适用于焊面平齐的等腰角焊缝。凸面或不等腰焊缝的焊喉不同。',
      '这里只考虑轴心受载。偏心载荷会在焊缝组上附加扭转或弯曲分量，'
          '必须与直接剪力按矢量合成。',
      '焊材强度通常与母材等强或略高，因此除非焊脚偏小，焊缝一般不起控制作用。',
    ],
    references: [
      'AWS D1.1, Structural Welding Code — Steel',
      'Shigley, Mechanical Engineering Design, ch. 9',
    ],
  ),
  708: ToolHelp(
    summary: '实心轴压入同种材料轮毂时的接触压力、轮毂环向应力和轴内应力。'
        '过盈配合是大多数齿轮和联轴器的实际连接方式——没有键槽，也就没有应力集中源。',
    formulas: [
      HelpFormula(
        tex: r'p = \frac{E\delta}{2d}\left[\frac{d_o^2-d^2}{d_o^2}\right]',
        plain: 'p = (E·δ / 2d) · (do² − d²)/do²',
        caption: '接触压力，两件同种材料',
      ),
      HelpFormula(
        tex: r'\sigma_{h} = p\,\frac{d_o^2+d^2}{d_o^2-d^2}, \quad '
            r'\sigma_{\text{shaft}} = -p',
        plain: 'σh = p·(do² + d²)/(do² − d²)，σshaft = −p',
        caption: '轮毂孔壁环向应力，以及轴内的均匀受压状态',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '直径过盈量', 'mm'),
      HelpSymbol('d', '配合面公称直径', 'mm'),
      HelpSymbol('do', '轮毂外径', 'mm'),
      HelpSymbol('p', '接触压力', 'MPa'),
      HelpSymbol('E', '弹性模量，按 GPa 输入', 'GPa'),
    ],
    notes: [
      '轴与轮毂同种材料，泊松比才能约去。异种材料需要用一般的拉梅公式，'
          '而钢轴装在铝轮毂里会随温度升高而松脱。',
      '轮毂孔壁的环向应力为拉应力，是接头中最大的应力。'
          '使薄壁轮毂开裂的是它，而不是接触压力。',
      '过盈量应按"配合"确定而非取名义值：实际过盈量在公差带内变化，'
          '两个极端都要校核——最小过盈校核传扭能力，最大过盈校核轮毂应力。',
      '装配时表面粗糙度会被压平，从而减小有效过盈量，应留出几个微米的余量。',
      '接头能传递的扭矩为 μ·p·π·d²·L/2，本工具不计算——'
          '它需要摩擦系数和配合长度，而这两项都不在输入之列。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 3 and 7',
      'ISO 286-1, Geometrical product specifications: ISO code system',
    ],
  ),
  709: ToolHelp(
    summary: '装有一个转子的轴的一阶横向临界转速，'
        '用邓克利公式把转子的涡动频率与轴自身分布质量的影响合成。'
        '在临界转速下运行时，微小的不平衡就会引起很大的挠度。',
    formulas: [
      HelpFormula(
        tex: r'\omega_r = \sqrt{\frac{k}{m}}, \quad '
            r'\frac{1}{\omega_c^2} = \frac{1}{\omega_r^2} + '
            r'\frac{1}{\omega_s^2}',
        plain: 'ωr = √(k/m)，1/ωc² = 1/ωr² + 1/ωs²',
        caption: '用邓克利公式合成转子与轴',
      ),
      HelpFormula(
        tex: r'N_c = \frac{60\,\omega_c}{2\pi}',
        plain: 'Nc = 60·ωc / (2π)',
        caption: '临界转速，单位 rpm',
      ),
    ],
    symbols: [
      HelpSymbol('k', '转子处的横向刚度', 'N/mm'),
      HelpSymbol('m', '转子质量', 'kg'),
      HelpSymbol('ωc', '一阶临界角频率', 'rad/s'),
      HelpSymbol('Nc', '一阶临界转速', 'rpm'),
    ],
    notes: [
      '邓克利公式总是偏低，因此给出的临界转速是保守的。这正是有利的偏保守方向。',
      '工作转速应留有充分裕度——通常低于一阶临界的约 75%，或高于其约 140%。'
          '升速过程中快速穿越临界转速是可以接受的。',
      '假定轴承为刚性。轴承或轴承座偏软会降低临界转速，有时降低幅度很大。',
      '不含使临界转速分裂为正进动与反进动的陀螺效应。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 10',
      'Shigley, Mechanical Engineering Design, ch. 7',
    ],
  ),
  710: ToolHelp(
    summary: '等截面直梁的横向固有频率，涵盖标准边界条件下的前三阶弯曲振型。'
        '固有频率与刚度质量比的平方根成正比，与长度的平方成反比。',
    formulas: [
      HelpFormula(
        tex: r'f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}',
        plain: 'fn = (βn·L)² / (2π·L²) · √(E·I / (ρ·A))',
        caption: '欧拉–伯努利梁的频率',
      ),
    ],
    symbols: [
      HelpSymbol('fn', '第 n 阶固有频率', 'Hz'),
      HelpSymbol('βnL', '由边界条件确定的特征值'),
      HelpSymbol('E·I', '抗弯刚度', 'N·mm²'),
      HelpSymbol('ρ·A', '单位长度质量', 'kg/m'),
      HelpSymbol('L', '跨度', 'mm'),
    ],
    notes: [
      '欧拉–伯努利理论忽略剪切变形和转动惯量，因此对粗短梁（L/d 小于约 10）'
          '和较高阶振型给出的频率偏高。铁摩辛柯理论对两者都作了修正。',
      '长度的影响占主导：跨度减半，各阶频率都提高到四倍。',
      '不属于梁本身的附加质量——电机、充满水的管道——会降低频率，'
          '除非把它折算进 ρA，否则本式不予考虑。',
      '实际边界条件从来不是理想固定或理想铰支，真实频率介于两种理想化之间。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 8',
      'Blevins, Formulas for Natural Frequency and Mode Shape',
    ],
  ),
  711: ToolHelp(
    summary: '圆轴的一阶扭转固有频率，适用于一端固定带一个转子，'
        '或自由轴两端各带一个转子的情形。扭转共振从外部看不出来，'
        '却是联轴器和轮齿失效的常见原因。',
    formulas: [
      HelpFormula(
        tex: r'k_t = \frac{GJ_p}{L}, \quad '
            r'\omega_n = \sqrt{\frac{k_t}{J_{\text{eff}}}}',
        plain: 'kt = G·Jp / L，ωn = √(kt / Jeff)',
        caption: '扭转刚度与频率',
      ),
      HelpFormula(
        tex: r'J_{\text{eff}} = \frac{J_1 J_2}{J_1+J_2}',
        plain: 'Jeff = J1·J2 / (J1 + J2)',
        caption: '自由轴带两个转子时的当量转动惯量',
      ),
    ],
    symbols: [
      HelpSymbol('kt', '扭转刚度', 'N·m/rad'),
      HelpSymbol('G', '剪切模量', 'MPa'),
      HelpSymbol('Jp', '轴的极惯性矩', 'mm⁴'),
      HelpSymbol('J1, J2', '两转子的转动惯量', 'kg·m²'),
    ],
    notes: [
      '忽略轴自身的转动惯量。当它与转子相当时，应改用多质量（霍尔泽）分析。',
      'Jp 是截面特性，单位 mm⁴；J1 和 J2 是转动惯量，单位 kg·m²。'
          '两者只是共用一个字母，混淆它们是这里最常见的错误。',
      '激励频率很少等于轴转速。发动机的发火次数和齿轮啮合频率都是它的倍数，'
          '而与共振相遇的通常正是这些倍频。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 5 and 6',
      'Nestorides, A Handbook on Torsional Vibration',
    ],
  ),
  800: ToolHelp(
    summary: '圆管内流动的雷诺数及其所属流态。Re 是惯性力与黏性力之比，'
        '它单独决定流动是有序还是紊乱，而流态又决定了摩擦系数和换热强度。',
    formulas: [
      HelpFormula(
        tex: r'Re = \frac{\rho V D}{\mu} = \frac{VD}{\nu}',
        plain: 'Re = ρ·V·D / μ = V·D / ν',
        caption: '雷诺数',
      ),
      HelpFormula(
        tex: r'V = \frac{Q}{A}, \quad A = \frac{\pi D^2}{4}',
        plain: 'V = Q / A，A = π·D²/4',
        caption: '由体积流量求流速',
      ),
    ],
    symbols: [
      HelpSymbol('Re', '雷诺数'),
      HelpSymbol('ρ', '密度', 'kg/m³'),
      HelpSymbol('V', '平均流速', 'm/s'),
      HelpSymbol('D', '管内径', 'mm'),
      HelpSymbol('μ', '动力黏度', 'Pa·s'),
      HelpSymbol('ν', '运动黏度，μ/ρ', 'm²/s'),
    ],
    notes: [
      '管内流动：低于约 2300 为层流，高于约 4000 为湍流，之间为过渡区。'
          '过渡并不是一个明确的界限，还与入口扰动和粗糙度有关。',
      'D 是管子的内径，而不是公称尺寸。请用管道壁厚系列表查得正确数值。',
      '非圆截面管道应改用水力直径 4A/P。它对湍流效果良好，对层流则较差。',
      'V 是截面平均流速。层流时中心线流速是它的两倍，湍流时约为 1.2 倍。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Munson, Fundamentals of Fluid Mechanics, ch. 8',
    ],
  ),
  801: ToolHelp(
    summary: '满管流动的达西–韦斯巴赫水头损失与压降，摩擦系数由科尔布鲁克公式求得，'
        '管件损失按速度头的倍数计入。这是管路选径以及为其选泵的标准方法。',
    formulas: [
      HelpFormula(
        tex: r'h_f = f\frac{L}{D}\frac{V^2}{2g}',
        plain: 'hf = f · (L/D) · V²/(2g)',
        caption: '达西–韦斯巴赫沿程水头损失',
      ),
      HelpFormula(
        tex: r'\frac{1}{\sqrt{f}} = -2\log_{10}\left(\frac{\varepsilon/D}'
            r'{3.7} + \frac{2.51}{Re\sqrt{f}}\right)',
        plain: '1/√f = −2·log₁₀[ (ε/D)/3.7 + 2.51/(Re·√f) ]',
        caption: '科尔布鲁克公式，需迭代求解',
      ),
      HelpFormula(
        tex: r'h_m = \sum K \frac{V^2}{2g}, \quad \Delta p = \rho g h',
        plain: 'hm = ΣK · V²/(2g)，Δp = ρ·g·h',
        caption: '局部损失与压降',
      ),
    ],
    symbols: [
      HelpSymbol('f', '达西摩擦系数'),
      HelpSymbol('L', '管长', 'm'),
      HelpSymbol('D', '管内径', 'mm'),
      HelpSymbol('ε', '绝对粗糙度', 'mm'),
      HelpSymbol('ΣK', '局部损失系数之和'),
      HelpSymbol('hf', '水头损失', 'm'),
    ],
    notes: [
      '达西摩擦系数是范宁摩擦系数的四倍。使用图表或关联式前请先确认它给的是哪一个——'
          '这个四倍关系是经典错误来源。',
      '科尔布鲁克公式适用于湍流。层流时应取 f = 64/Re，与粗糙度完全无关。',
      '常见绝对粗糙度：商用钢管 0.045 mm，冷拔管 0.0015 mm，铸铁管 0.26 mm。'
          '旧管远比新管粗糙，不确定性主要来自这里。',
      '假定为不可压缩流体的满管稳定流动。半满的重力排水管和可压缩气体流动'
          '需要另行处理。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Crane Technical Paper No. 410, Flow of Fluids Through Valves, '
          'Fittings and Pipe',
    ],
  ),
  802: ToolHelp(
    summary: '泵或风机所需的功率：流体获得的是压升乘流量，'
        '而原动机必须提供的是它除以效率。同时把压升换算为所输送流体的扬程，'
        '因为泵的性能曲线正是这样绘制的。',
    formulas: [
      HelpFormula(
        tex: r'P_{\text{fluid}} = \Delta p\,Q, \quad '
            r'P_{\text{shaft}} = \frac{\Delta p\,Q}{\eta}',
        plain: 'Pfluid = Δp·Q，Pshaft = Δp·Q / η',
        caption: '水力功率与轴功率',
      ),
      HelpFormula(
        tex: r'H = \frac{\Delta p}{\rho g}',
        plain: 'H = Δp / (ρ·g)',
        caption: '把压升表示为扬程',
      ),
    ],
    symbols: [
      HelpSymbol('Δp', '通过机器的压升', 'kPa'),
      HelpSymbol('Q', '体积流量', 'm³/s'),
      HelpSymbol('η', '总效率'),
      HelpSymbol('H', '扬程', 'm'),
    ],
    notes: [
      '扬程与密度无关，而压力与密度有关。同一台泵对任何液体产生的扬程相同，'
          '而对较轻的液体压力按比例降低——泵的性能曲线用米作单位正是这个原因。',
      '这里的效率是整机效率。若电机效率另计，还要再除以它才能得到电功率输入。',
      '还应校核可用汽蚀余量是否大于泵的必需汽蚀余量。'
          '发生汽蚀的泵无论功率怎么选都无法有效输出。',
      '对输送空气的风机，只有压升较小时（低于绝对压力的约 3%）才可按不可压缩处理。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 11',
      'Hydraulic Institute Standards, ANSI/HI 1.1-1.2',
    ],
  ),
  810: ToolHelp(
    summary: '多层平壁的一维稳态导热。各层是串联的热阻，'
        '与两侧表面的对流膜阻串联相加，由此得到总传热系数、热流量以及各界面的温度。',
    formulas: [
      HelpFormula(
        tex: r'R_{\text{cond}} = \frac{t}{k}, \quad '
            r'R_{\text{conv}} = \frac{1}{h}',
        plain: 'Rcond = t/k，Rconv = 1/h',
        caption: '单位面积热阻',
      ),
      HelpFormula(
        tex: r'U = \frac{1}{\sum R}, \quad q = U\,\Delta T',
        plain: 'U = 1 / ΣR，q = U · ΔT',
        caption: '总传热系数与热流密度',
      ),
    ],
    symbols: [
      HelpSymbol('t', '层厚', 'm'),
      HelpSymbol('k', '导热系数', 'W/m·K'),
      HelpSymbol('h', '对流换热系数', 'W/m²·K'),
      HelpSymbol('U', '总传热系数', 'W/m²·K'),
      HelpSymbol('q', '热流密度', 'W/m²'),
    ],
    notes: [
      '仅适用于平壁，热阻按 t/k 相加。圆筒壁和球壁分别是对数形式和倒数形式，'
          '把平壁公式用在小直径管道上会有明显误差。',
      '最大的那个热阻起控制作用。若某面墙的热阻已由静止空气膜主导，'
          '再加保温层的效果会远小于 k 值所暗示的。',
      '不计各层之间的接触热阻，而它对螺栓连接或粘接的金属接头可能相当重要。',
      '仅为稳态：不含热容，因此说明不了墙体的响应时间。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'ASHRAE Handbook — Fundamentals, ch. 25',
    ],
  ),
  811: ToolHelp(
    summary: '等截面矩形直肋的效率，按绝热肋端并采用修正长度求解。'
        '肋效率表示在肋温沿长度下降的实际情况下，肋所达到的散热量与理想散热量之比。',
    formulas: [
      HelpFormula(
        tex: r'm = \sqrt{\frac{2h}{kt}}, \quad L_c = L + \frac{t}{2}',
        plain: 'm = √(2h / (k·t))，Lc = L + t/2',
        caption: '肋参数与修正长度',
      ),
      HelpFormula(
        tex: r'\eta_f = \frac{\tanh(mL_c)}{mL_c}',
        plain: 'ηf = tanh(m·Lc) / (m·Lc)',
        caption: '肋效率',
      ),
    ],
    symbols: [
      HelpSymbol('h', '对流换热系数', 'W/m²·K'),
      HelpSymbol('k', '肋的导热系数', 'W/m·K'),
      HelpSymbol('t', '肋厚', 'm'),
      HelpSymbol('L', '肋长', 'm'),
      HelpSymbol('ηf', '肋效率'),
    ],
    notes: [
      '修正长度是绝热肋端解中考虑肋端对流的标准处理。'
          '当 h·t/k 较小时（通常如此）精度良好。',
      '肋越长效率越低：mLc 超过约 2 之后，再加长只增加重量而几乎不增加散热。'
          '这就是肋高的实际上限。',
      '只有表面热阻占主导时加肋才有意义。在 h 本已很大的换热器水侧加肋，作用很小。',
      '假定肋内为一维导热，表面 h 均匀，且不计辐射。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'Kraus, Aziz & Welty, Extended Surface Heat Transfer',
    ],
  ),
  812: ToolHelp(
    summary: '由四个进出口温度求对数平均温差，以及达到给定热负荷所需的换热面积。'
        '对数平均温差才是换热器正确的平均传热温差，'
        '因为局部温差沿流程是按指数而非线性变化的。',
    formulas: [
      HelpFormula(
        tex: r'\Delta T_{lm} = \frac{\Delta T_1 - \Delta T_2}'
            r'{\ln(\Delta T_1/\Delta T_2)}',
        plain: 'ΔTlm = (ΔT1 − ΔT2) / ln(ΔT1/ΔT2)',
        caption: '对数平均温差',
      ),
      HelpFormula(
        tex: r'A = \frac{Q}{U\,\Delta T_{lm}}',
        plain: 'A = Q / (U · ΔTlm)',
        caption: '给定热负荷所需的面积',
      ),
    ],
    symbols: [
      HelpSymbol('ΔT1, ΔT2', '两端的温差', 'K'),
      HelpSymbol('U', '总传热系数', 'W/m²·K'),
      HelpSymbol('Q', '热负荷', 'W'),
      HelpSymbol('A', '传热面积', 'm²'),
    ],
    notes: [
      '逆流是各自的进口与对方的出口配对，顺流是两个进口配对。'
          '逆流的对数平均温差总是更大，因而换热器更小，'
          '而且只有逆流才可能使冷流体出口温度高于热流体出口温度。',
      '管壳式或错流式布置还要乘以标准图表中的修正系数 F。'
          'F 低于约 0.8 说明所选流程布置不合理。',
      '假定 U 和比热沿换热器保持不变，且无相变。'
          '一侧发生冷凝或沸腾时需要分段计算。',
      '污垢会随时间增大热阻；设计 U 值应计入污垢裕量，否则换热器一年内就会偏小。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 11',
      'TEMA Standards of the Tubular Exchanger Manufacturers Association',
    ],
  ),
  500: ToolHelp(
    summary: '在同一物理量的不同单位之间换算——长度、力、压力、扭矩等。'
        '凡定义本身是精确的，换算就是精确的；对基于英寸的单位大多如此：'
        '自 1959 年起，1 英寸就精确等于 25.4 mm。',
    formulas: [
      HelpFormula(
        tex: r'v_{\text{target}} = v_{\text{source}} \times '
            r'\frac{f_{\text{source}}}{f_{\text{target}}}',
        plain: '目标值 = 源值 × (源系数 / 目标系数)',
        caption: '所有换算都经过同一个 SI 基准值',
      ),
    ],
    symbols: [
      HelpSymbol('f', '把某单位换算为其 SI 基准的系数'),
    ],
    notes: [
      '通过单一 SI 基准换算而不是单位对单位换算，意味着每个单位只需一个系数，'
          '而不是每一对单位一个，因此 n 个单位的表格不会自相矛盾。',
      '温度是例外：°C 与 °F 之间既有比例又有偏移量，'
          '因此温"差"的换算方式与温度本身不同。',
      '磅力与磅质量是名称相近的两个不同物理量。换算前请先确认数值指的是哪一个。',
    ],
    references: [
      'BIPM, The International System of Units (SI), 9th edition',
      'NIST Special Publication 811, Guide for the Use of the SI',
    ],
  ),
  501: ToolHelp(
    summary: '标准公制和英制螺纹的底孔与过孔尺寸。'
        '底孔尺寸留下的材料约相当于 75% 的螺纹啮合率——'
        '这是螺纹强度与攻丝扭矩之间的实用折中。',
    formulas: [
      HelpFormula(
        tex: r'd_{\text{tap}} \approx D - P',
        plain: '底孔 ≈ D − P（公制，约 75% 螺纹）',
        caption: '大径减去一个螺距——常用的 75% 规则',
      ),
    ],
    symbols: [
      HelpSymbol('D', '螺纹公称大径', 'mm'),
      HelpSymbol('P', '螺距', 'mm'),
    ],
    notes: [
      'D − P 并不是小径：基本小径为 D − 1.0825·P，'
          '常用底孔有意留下较浅的螺纹。',
      '螺纹啮合率从 75% 提高到 100%，强度只增加约 5%，而攻丝扭矩却几乎翻倍。'
          '这样做几乎从不划算，而且容易断丝锥。',
      '螺纹强度更多取决于啮合"长度"而非啮合百分比。'
          '在软材料中应加长螺纹，而不是把孔攻得更深。',
      '过孔按紧、中、松三种配合等级选取，除非装配需要调整余量，一般取中等。',
      '挤压丝锥（滚丝锥）需要比切削丝锥更大的底孔——它是挤压材料而不是切除材料。',
    ],
    references: [
      'ISO 965-1, ISO general purpose metric screw threads — Tolerances',
      'Machinery\'s Handbook, Threads and Threading',
    ],
  ),
  502: ToolHelp(
    summary: 'ISO 286 优先选用的基孔制配合的极限偏差。'
        '一种配合是一对公差带：字母决定公差带相对于公称尺寸的位置，'
        '数字决定其宽度，因此 H7/g6 与 H7/p6 的差别在位置而不在精度。',
    formulas: [
      HelpFormula(
        tex: r'\text{clearance}_{\max} = \text{hole}_{\max} - '
            r'\text{shaft}_{\min}',
        plain: '最大间隙 = 孔的最大值 − 轴的最小值',
        caption: '最小间隙则为孔的最小值 − 轴的最大值',
      ),
    ],
    symbols: [
      HelpSymbol('H', '基孔制：下偏差为零'),
      HelpSymbol('IT', '标准公差等级——公差带的宽度'),
      HelpSymbol('µm', '偏差以微米列表'),
    ],
    notes: [
      '通常采用基孔制：孔用定尺寸刀具加工，而轴更容易调整，因此改轴更经济。',
      '间隙为负即为过盈。H7/p6 及更紧的配合属于压入配合，'
          '应使用过盈配合工具校核轮毂应力。',
      '同一 IT 等级的公差带宽度随尺寸增大：IT7 在 20 mm 处为 21 µm，'
          '在 300 mm 处为 52 µm。',
      '表中只给出极限尺寸。轴能否装得进去还取决于形状误差：'
          '圆度和直线度误差会占用间隙。',
    ],
    references: [
      'ISO 286-1 and ISO 286-2, Geometrical product specifications',
      'Machinery\'s Handbook, Allowances and Tolerances for Fits',
    ],
  ),
  503: ToolHelp(
    summary: '热轧型钢的公布尺寸和截面特性——AISC 的 W 型钢以及欧标 IPE 和 HEB。'
        '公布值包含了裸几何计算看不到的轧制圆角，这部分约占面积和刚度的百分之几。',
    formulas: [
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c，r = √(I / A)',
        caption: '截面模量与回转半径，二者均在此处导出',
      ),
    ],
    symbols: [
      HelpSymbol('A', '横截面积', 'mm²'),
      HelpSymbol('Ix, Iy', '绕强轴与弱轴的惯性矩', 'mm⁴'),
      HelpSymbol('S', '弹性截面模量', 'mm³'),
      HelpSymbol('r', '回转半径', 'mm'),
    ],
    notes: [
      '库中只存储面积和两个惯性矩，S 与 r 由它们算出，因此抄录出错也不会造成互相矛盾。',
      '表中收录的是双轴对称的工字形截面。槽钢和角钢的形心不在半高处，未予收录。',
      '这些是弹性特性。塑性设计使用塑性截面模量 Z，它更大——'
          '典型工字形截面约为 S 的 1.12 倍。',
      '出图前请核对现行的轧制表或标准：型号偶有修订或废止。',
    ],
    references: [
      'AISC Steel Construction Manual, Part 1',
      'EN 10365, Hot rolled steel channels, I and H sections',
    ],
  ),
  504: ToolHelp(
    summary: 'ASME B36.10M 钢管的外径、壁厚和内径。'
        '钢管按固定外径制造，使同一套管件和螺纹适用于各种壁厚，'
        '因此壁厚系列加大只会缩小内径，而不会增大管子。',
    formulas: [
      HelpFormula(
        tex: r'ID = OD - 2t, \quad A = \frac{\pi\,ID^2}{4}',
        plain: 'ID = OD − 2·t，A = π·ID²/4',
        caption: '内径与流通面积，二者均在此处导出',
      ),
    ],
    symbols: [
      HelpSymbol('NPS', '公称管径代号——是名称，不是尺寸'),
      HelpSymbol('DN', 'ISO 公称直径，同样是名称'),
      HelpSymbol('OD', '外径', 'mm'),
      HelpSymbol('t', '壁厚', 'mm'),
    ],
    notes: [
      'NPS 不是尺寸。NPS 2 的管子内径不是 2 英寸，外径也不是；'
          '只有 NPS 14 及以上，该数字才等于以英寸计的外径。',
      '任何流动计算都应使用内径而不是公称尺寸。NPS 1 时二者相差约 20%，'
          '而在压降计算中这一差别是按四次方放大的。',
      'STD 与 XS 分别只到 NPS 10 和 NPS 8 才与 Sch 40、Sch 80 一致；'
          '再往上，这两个重量等级的壁厚就不再增加了。',
      '这些是公称尺寸。壁厚的轧制负偏差通常为 −12.5%，做承压计算时需要注意。',
    ],
    references: [
      'ASME B36.10M, Welded and Seamless Wrought Steel Pipe',
      'ASME B31.3, Process Piping',
    ],
  ),
  505: ToolHelp(
    summary: '对一列尺寸做一维公差累加，同时给出极值法和统计法（RSS）的结果。'
        '输出封闭环间隙、它是否可能为负，以及哪一个尺寸造成了大部分变动——'
        '收紧那个尺寸的公差收益最大。',
    formulas: [
      HelpFormula(
        tex: r'g = \sum \pm d_i, \quad '
            r'T_{wc} = \sum t_i',
        plain: 'g = Σ ±di，Twc = Σ ti',
        caption: '极值法：公差按代数和相加',
      ),
      HelpFormula(
        tex: r'T_{rss} = \sqrt{\sum t_i^2}',
        plain: 'Trss = √(Σ ti²)',
        caption: 'RSS：公差按平方和相加',
      ),
    ],
    symbols: [
      HelpSymbol('di', '链中各尺寸的基本值', 'mm'),
      HelpSymbol('ti', '各尺寸的对称半公差', 'mm'),
      HelpSymbol('g', '封闭环间隙', 'mm'),
    ],
    notes: [
      '极值法只是加减运算，结论无可争辩：只要它通过，装配就一定能装上。应按它定尺寸。',
      'RSS 假定各尺寸独立变动、位于公差带中间且近似正态分布。'
          '对五件这样的小批量它没有意义；工序发生偏移或供应商长期靠着公差带一侧生产时，'
          '它会低估变动。',
      'RSS 的占比按各公差的平方计算，因此比极值法占比更强烈地指向最松的那个尺寸，'
          '那就是应当收紧的对象。',
      '非对称公差会使统计平均值偏移：25 +0.10/−0.00 实际上是 25.05 ±0.05，'
          '按 25 累加会使整条尺寸链偏低。',
      '仅限一维。角度影响、形状误差和位置度公差需要完整的三维公差分析。',
    ],
    references: [
      'ASME Y14.5, Dimensioning and Tolerancing',
      'Fischer, Mechanical Tolerance Stackup and Analysis',
    ],
  ),
};
