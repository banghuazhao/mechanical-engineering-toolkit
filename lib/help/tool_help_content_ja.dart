import 'package:mechanical_engineering_toolkit/help/tool_help.dart';

/// Japanese tool explanations.
///
/// Equations, symbol glyphs and units are left untranslated — they are the
/// same notation on a drawing in any language. References stay in English
/// because they are citations: a reader looking the book up needs the title it
/// was published under.
const Map<int, ToolHelp> toolHelpJa = {
  100: ToolHelp(
    summary: '軸方向荷重を受ける等断面棒の一軸応力とひずみ。垂直応力は荷重を'
        '抵抗断面積で割った値であり、材料が弾性の範囲にあるかぎり、'
        'ひずみはフックの法則から求まります。タイロッド、吊り棒、'
        '純引張のボルトなど、他のあらゆる応力計算の出発点です。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A}',
        plain: 'σ = P / A',
        caption: '垂直応力',
      ),
      HelpFormula(
        tex: r'\varepsilon = \frac{\sigma}{E} = \frac{\delta}{L}',
        plain: 'ε = σ / E = δ / L',
        caption: '弾性範囲でのひずみ',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '垂直応力', 'MPa'),
      HelpSymbol('P', '軸方向力、引張を正とする', 'N'),
      HelpSymbol('A', '断面積', 'mm²'),
      HelpSymbol('E', '縦弾性係数（ヤング率）', 'MPa'),
      HelpSymbol('ε', '垂直ひずみ'),
    ],
    notes: [
      '応力が断面内で一様であることを前提とします。これは荷重点、穴、'
          '断面変化から離れた位置で成り立ちます（サン・ブナンの原理）。'
          'それらの近くでは、この式では見えない応力集中が生じます。',
      '弾性範囲のみ。σ が比例限度を超えると ε = σ/E は成り立たなくなり、'
          '棒には永久ひずみが残ります。',
      '細長い部材の圧縮では、この応力に達するはるか手前で座屈します。'
          '柱の座屈ツールでも確認してください。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 1–3',
      'Gere & Goodno, Mechanics of Materials, ch. 1',
    ],
    diagram: 'images/icon_bar_force.png',
  ),
  101: ToolHelp(
    summary: '等断面棒の軸方向の伸びと、それに対応する剛性。棒はばね定数 AE/L の'
        '線形ばねとしてふるまうため、この関係はボルト継手、タイロッド構造、'
        'および剛性の重ね合わせで解くあらゆる構造の基本要素になります。',
    formulas: [
      HelpFormula(
        tex: r'\delta = \frac{PL}{AE}',
        plain: 'δ = P·L / (A·E)',
        caption: '伸び',
      ),
      HelpFormula(
        tex: r'k = \frac{AE}{L}',
        plain: 'k = A·E / L',
        caption: '軸方向剛性',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '伸び、引張を正とする', 'mm'),
      HelpSymbol('P', '軸方向力', 'N'),
      HelpSymbol('L', '元の長さ', 'mm'),
      HelpSymbol('A', '断面積', 'mm²'),
      HelpSymbol('E', '縦弾性係数', 'MPa'),
      HelpSymbol('k', '軸方向剛性', 'N/mm'),
    ],
    notes: [
      '長さ方向に P、A、E が一定な等断面棒に適用できます。段付き棒、'
          'テーパ棒、自重を考慮する場合は、区間に分けて伸びを足し合わせてください。',
      '微小ひずみの線形弾性理論です。δ は変形後ではなく元の長さに基づいて計算されます。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/bar_force_displacement.png',
  ),
  103: ToolHelp(
    summary: '純ねじりを受ける円形軸のせん断応力。応力は中心の零から表面の最大値まで'
        '直線的に増加するため、外径が同じであれば中空軸は中実軸とほぼ同等の'
        'トルクを伝達しながら、はるかに軽くできます。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{T\rho}{J}',
        plain: 'τ = T·ρ / J',
        caption: '半径 ρ でのせん断応力',
      ),
      HelpFormula(
        tex: r'J_{\text{solid}} = \frac{\pi d^4}{32}, \quad '
            r'J_{\text{hollow}} = \frac{\pi (d_o^4 - d_i^4)}{32}',
        plain: 'J = π·d⁴/32（中実）、J = π·(do⁴ − di⁴)/32（中空）',
        caption: '断面二次極モーメント',
      ),
    ],
    symbols: [
      HelpSymbol('τ', 'せん断応力', 'MPa'),
      HelpSymbol('T', 'ねじりモーメント', 'N·mm'),
      HelpSymbol('ρ', '着目点の半径', 'mm'),
      HelpSymbol('J', '断面二次極モーメント', 'mm⁴'),
    ],
    notes: [
      '円形断面のみ。非円形断面はねじると面外に反り（そり変形）を生じ、'
          'この式はまったく適用できません。角棒や長方形棒には固有のねじり定数が必要です。',
      '線形弾性かつ純ねじり。曲げとねじりの組合せは組合せ荷重ツールで求めてから、'
          '強度理論で評価してください。',
      '他の量が mm と MPa のときは、T は N·mm で入力します。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Gere & Goodno, Mechanics of Materials, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  114: ToolHelp(
    summary: 'トルクを受けた軸の一端が他端に対して回転する角度。ねじり角は'
        '伝動軸の剛性感、トーションバーが狙いのばね定数になるか、'
        'そして不静定系でトルクが並列経路にどう分配されるかを決めます。',
    formulas: [
      HelpFormula(
        tex: r'\phi = \frac{TL}{GJ}',
        plain: 'φ = T·L / (G·J)',
        caption: 'ねじり角（ラジアン）',
      ),
      HelpFormula(
        tex: r'k_t = \frac{GJ}{L}',
        plain: 'kt = G·J / L',
        caption: 'ねじり剛性',
      ),
    ],
    symbols: [
      HelpSymbol('φ', 'ねじり角', 'rad'),
      HelpSymbol('T', 'ねじりモーメント', 'N·mm'),
      HelpSymbol('L', 'ねじれが生じる長さ', 'mm'),
      HelpSymbol('G', '横弾性係数', 'MPa'),
      HelpSymbol('J', '断面二次極モーメント', 'mm⁴'),
    ],
    notes: [
      'T、G、J が長さ方向に一定な等断面円形軸に適用できます。'
          'いずれかが変化する場合は区間ごとのねじり角を足し合わせてください。',
      'G は E から独立ではありません。等方性材料では G = E / [2(1 + ν)] で、'
          '鋼ではおよそ 0.385·E です。',
      '結果はラジアンです。度にするには 180/π を掛けてください。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 5',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
    diagram: 'images/icon_bar_torsion.png',
  ),
  115: ToolHelp(
    summary: '与えられた動力と回転数で回転軸が伝えるトルク、または既知のトルクから'
        '求まる動力。軸の設計はここから始まります。モータの銘板は動力と回転数を'
        '与え、軸はそこから導かれるトルクに対して設計しなければなりません。',
    formulas: [
      HelpFormula(
        tex: r'P = T\omega, \quad \omega = \frac{2\pi n}{60}',
        plain: 'P = T·ω、ω = 2π·n / 60',
        caption: 'トルクと回転数から動力を求める',
      ),
      HelpFormula(
        tex: r'T = \frac{9549\,P_{\text{kW}}}{n}',
        plain: 'T [N·m] = 9549 · P [kW] / n [rpm]',
        caption: '実用形',
      ),
    ],
    symbols: [
      HelpSymbol('P', '伝達動力', 'W'),
      HelpSymbol('T', 'トルク', 'N·m'),
      HelpSymbol('ω', '角速度', 'rad/s'),
      HelpSymbol('n', '回転数', 'rpm'),
    ],
    notes: [
      'これは定常回転で伝達されるトルクです。始動、制動、拘束時のトルクは'
          '数倍になることがあるため、軸を決める前にサービスファクタを掛けてください。',
      '入る動力と出る動力：伝動装置の損失は効率で割ることにより別途考慮します。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'Hibbeler, Mechanics of Materials, ch. 5',
    ],
  ),
  109: ToolHelp(
    summary: '薄肉球形圧力容器の壁に生じる膜応力。球は圧力を保持する形状として'
        '最も効率がよく、応力はどの方向にも等しく、同じ半径・板厚の円筒の'
        '周方向応力の半分になります。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{pr}{2t}',
        plain: 'σ = p·r / (2·t)',
        caption: '膜応力、全方向で等しい',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '膜応力', 'MPa'),
      HelpSymbol('p', '内部ゲージ圧', 'MPa'),
      HelpSymbol('r', '内半径', 'mm'),
      HelpSymbol('t', '板厚', 'mm'),
    ],
    notes: [
      '薄肉理論であり、r/t がおよそ 10 を超える範囲で有効です。'
          'それ以下では応力が板厚方向に変化し、厚肉（ラメ）解が必要になります。',
      '膜応力のみです。ノズル、支持部、他形状との接合部では局部応力が'
          'これを大きく上回り、圧力容器規格が多くの頁を割いているのはその点です。',
      'ASME VIII などの規格に基づく設計では溶接継手効率と腐れ代が加わります。'
          'ここでは純粋な力学のみを扱います。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_spherical_shell_stress.png',
  ),
  110: ToolHelp(
    summary: '内圧を受ける薄肉円筒の周方向および軸方向の膜応力。周方向応力は'
        '軸方向応力の 2 倍であり、加圧された管が円周方向ではなく長手方向に'
        '裂けるのはこのためです。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_h = \frac{pr}{t}',
        plain: 'σh = p·r / t',
        caption: '周方向（フープ）応力',
      ),
      HelpFormula(
        tex: r'\sigma_l = \frac{pr}{2t}',
        plain: 'σl = p·r / (2·t)',
        caption: '軸方向応力',
      ),
    ],
    symbols: [
      HelpSymbol('σh', '周方向応力', 'MPa'),
      HelpSymbol('σl', '軸方向応力', 'MPa'),
      HelpSymbol('p', '内部ゲージ圧', 'MPa'),
      HelpSymbol('r', '内半径', 'mm'),
      HelpSymbol('t', '板厚', 'mm'),
    ],
    notes: [
      '薄肉理論であり、r/t がおよそ 10 を超える範囲で有効です。',
      'この 2 つは壁面における主応力であり、3 つめはほぼ零です。'
          '強度理論ツールに入力すれば相当応力が得られます。',
      '軸方向応力は円筒が閉じている場合にのみ生じます。'
          '別の方法で拘束された開放管では軸方向荷重が異なります。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'ASME BPVC Section VIII, Division 1, UG-27',
    ],
    diagram: 'images/icon_cylindrical_pressure_stress.png',
  ),
  107: ToolHelp(
    summary: '平面応力状態を任意の座標軸へ回転させます。同じ物理的な応力状態でも、'
        '見る面によって読み取れる値は変わります。応力変換は、部品の座標軸と'
        '一致しない溶接線、接着面、繊維方向に生じる応力を求めるためのものです。',
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
      HelpSymbol('σx, σy', '元の座標軸における垂直応力', 'MPa'),
      HelpSymbol('τxy', '元の座標軸におけるせん断応力', 'MPa'),
      HelpSymbol('θ', '新しい軸への回転角、反時計回りを正とする', '°'),
    ],
    notes: [
      '平面応力：第 3 主応力は零です。面内荷重を受ける薄板には良いモデルですが、'
          '厚い物体の内部には適しません。',
      '符号の約束：引張の垂直応力を正とし、+x 面に +y 方向に作用するせん断応力を'
          '正とします。ここでの符号の取り違えが誤答の主な原因です。',
      '変換式では角度が 2 倍で現れます。モールの応力円が描いているのはまさにこれで、'
          '同じ関係を幾何学的に表したものです。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  108: ToolHelp(
    summary: 'ある点における最大・最小の垂直応力と、それらが作用する面。'
        '多くの強度理論は主応力で表されるため、これは応力解析と安全率の'
        '間に位置する段階になります。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{1,2} = \frac{\sigma_x+\sigma_y}{2} \pm '
            r'\sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}',
        plain: 'σ1,2 = (σx+σy)/2 ± √[ ((σx−σy)/2)² + τxy² ]',
        caption: '主応力',
      ),
      HelpFormula(
        tex: r'\tan 2\theta_p = \frac{2\tau_{xy}}{\sigma_x-\sigma_y}',
        plain: 'tan2θp = 2·τxy / (σx − σy)',
        caption: '主応力面の方向',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{\sigma_1-\sigma_2}{2}',
        plain: 'τmax = (σ1 − σ2) / 2',
        caption: '面内最大せん断応力',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '主応力、σ1 ≥ σ2', 'MPa'),
      HelpSymbol('θp', 'x 軸から σ1 の面までの角度', '°'),
      HelpSymbol('τmax', '面内最大せん断応力', 'MPa'),
    ],
    notes: [
      '主応力面にはせん断応力が生じません。それが主応力面の定義です。',
      '平面応力では第 3 主応力が零ですが、それが 3 つのうち最小になることもあります。'
          '真の最大せん断応力は 3 つすべてについての (σmax − σmin)/2 であり、'
          'σ1 と σ2 が同符号のときは面内の値を上回ります。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 2',
    ],
    diagram: 'images/icon_stress_element.png',
  ),
  118: ToolHelp(
    summary: 'モールの応力円は、応力変換を幾何学として描いたものです。'
        'その点を通るあらゆる面が円上の 1 点に対応し、中心は平均垂直応力、'
        '半径は面内最大せん断応力になるため、主応力とその方向が一目で読み取れます。',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{\sigma_x+\sigma_y}{2}, \quad '
            r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2+\tau_{xy}^2}',
        plain: 'C = (σx+σy)/2、R = √[ ((σx−σy)/2)² + τxy² ]',
        caption: '中心と半径',
      ),
      HelpFormula(
        tex: r'\sigma_{1,2} = C \pm R, \quad \tau_{\max} = R',
        plain: 'σ1,2 = C ± R、τmax = R',
      ),
    ],
    symbols: [
      HelpSymbol('C', '円の中心、すなわち平均垂直応力', 'MPa'),
      HelpSymbol('R', '円の半径、すなわち面内最大せん断応力', 'MPa'),
      HelpSymbol('σx, σy, τxy', '描かれる応力状態', 'MPa'),
    ],
    notes: [
      '円を 1 周すると、実際の要素は 180° 回転したことになります。'
          '円上の角度は実際の角度の 2 倍です。',
      '平面応力のみです。完全な三次元応力状態は 3 つの円で表され、'
          '最も外側の円が最大せん断応力を支配します。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 9',
      'Gere & Goodno, Mechanics of Materials, ch. 7',
    ],
    diagram: 'images/icon_stress_element_inclined.png',
  ),
  116: ToolHelp(
    summary: '二次元の応力状態を、降伏強さと比較できる 1 つの相当応力に換算します。'
        'ミーゼス（せん断ひずみエネルギー）説は延性金属の標準的な選択で、'
        'トレスカ（最大せん断応力）説はやや安全側で、いくつかの圧力容器規格が'
        '今も採用しています。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}',
        plain: 'σVM = √(σ1² − σ1·σ2 + σ2²)',
        caption: 'ミーゼス、平面応力',
      ),
      HelpFormula(
        tex: r'\sigma_{Tresca} = |\sigma_1 - \sigma_2|',
        plain: 'σTresca = |σ1 − σ2|',
        caption: 'トレスカ相当応力',
      ),
      HelpFormula(
        tex: r'n = \frac{S_y}{\sigma_{eq}}',
        plain: 'n = Sy / σeq',
        caption: '降伏に対する安全率',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '主応力', 'MPa'),
      HelpSymbol('σVM', 'ミーゼス相当応力', 'MPa'),
      HelpSymbol('Sy', '降伏強さ', 'MPa'),
      HelpSymbol('n', '安全率'),
    ],
    notes: [
      'いずれも延性材料の降伏を予測するものです。ぜい性材料は最大主応力説または'
          'モール・クーロン説で破壊するため、ミーゼス説を鋳鉄に適用すると'
          '誤った判断につながります。',
      'トレスカは 2 つのうち安全側で、その差は最大で約 15% です。'
          '単軸引張では一致し、純せん断で最も差が開きます。',
      '静的な降伏のみを扱います。変動荷重には疲労の判定基準が必要です。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 5',
      'Hibbeler, Mechanics of Materials, ch. 10',
    ],
  ),
  119: ToolHelp(
    summary: '平均応力が零でない変動荷重を受ける部品の安全率を、修正グッドマン線図'
        'によって求めます。引張の平均応力は、変動成分だけから予想されるよりも'
        '疲労を厳しくします。グッドマンはそれを考慮する標準的で'
        'やや安全側の方法です。',
    formulas: [
      HelpFormula(
        tex: r'\frac{\sigma_a}{S_e} + \frac{\sigma_m}{S_{ut}} = \frac{1}{n}',
        plain: 'σa/Se + σm/Sut = 1/n',
        caption: '修正グッドマン線',
      ),
      HelpFormula(
        tex: r'\sigma_a = \frac{\sigma_{\max}-\sigma_{\min}}{2}, \quad '
            r'\sigma_m = \frac{\sigma_{\max}+\sigma_{\min}}{2}',
        plain: 'σa = (σmax − σmin)/2、σm = (σmax + σmin)/2',
        caption: '変動成分と平均成分',
      ),
    ],
    symbols: [
      HelpSymbol('σa', '応力振幅', 'MPa'),
      HelpSymbol('σm', '平均応力', 'MPa'),
      HelpSymbol('Se', '修正後の疲労限度', 'MPa'),
      HelpSymbol('Sut', '引張強さ', 'MPa'),
      HelpSymbol('n', '疲労に対する安全率'),
    ],
    notes: [
      'Se を空欄にすると 0.5·Sut を用います。これは鋼に対する一般的な初期見積りです。'
          '未修正の値であり、実際の設計では表面、寸法、荷重、温度、信頼度の'
          'マリン係数を掛けます。通常はそこからさらに半減します。',
      '非鉄金属やアルミニウムには真の疲労限度がなく、繰返し数とともに強度が'
          '下がり続けるため、この式ではなく有限寿命の計算が必要です。',
      '圧縮の平均応力は同じようには損傷を与えません。負の σm にグッドマンを'
          '適用すると過度に安全側になるため、その場合は σm = 0 としてください。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 6',
      'Norton, Machine Design, ch. 6',
    ],
  ),
  112: ToolHelp(
    summary: '棒の自由な熱膨張と、その膨張が拘束されたときに生じる応力。'
        '完全拘束された部材に生じる応力は材料と温度差だけで決まり、'
        '長さにも断面積にも依存しません。長い配管に厚い管ではなく'
        '伸縮継手が必要なのはこのためです。',
    formulas: [
      HelpFormula(
        tex: r'\delta_T = \alpha \, \Delta T \, L',
        plain: 'δT = α · ΔT · L',
        caption: '自由膨張量',
      ),
      HelpFormula(
        tex: r'\sigma_T = -E \alpha \, \Delta T',
        plain: 'σT = −E · α · ΔT',
        caption: '完全拘束時の応力',
      ),
    ],
    symbols: [
      HelpSymbol('δT', '自由な長さ変化', 'mm'),
      HelpSymbol('α', '線膨張係数', '1/°C'),
      HelpSymbol('ΔT', '温度変化', '°C'),
      HelpSymbol('L', '元の長さ', 'mm'),
      HelpSymbol('σT', '熱応力、加熱時は圧縮', 'MPa'),
    ],
    notes: [
      '拘束応力は L と A に依存しません。部材を太くしても下がらず、'
          '動けるようにするか ΔT を小さくするしかありません。',
      '完全拘束は最も厳しい場合です。部分拘束ではこの値と零の間の値になり、'
          'どれだけ変位が妨げられるかに比例します。',
      'α は温度によって変わります。温度範囲が広い場合は室温の値ではなく'
          '区間の平均値を用いてください。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 2',
    ],
  ),
  111: ToolHelp(
    summary: '細長い柱が安定を失って横にたわみ出す軸方向荷重。座屈は強度ではなく'
        '剛性の問題です。座屈荷重は E と I で決まり、材料の強さにはほとんど'
        '依存しません。長い柱は降伏荷重のごく一部で座屈することがあります。',
    formulas: [
      HelpFormula(
        tex: r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}',
        plain: 'Pcr = π²·E·I / (K·L)²',
        caption: 'オイラーの座屈荷重',
      ),
      HelpFormula(
        tex: r'\sigma_{cr} = \frac{P_{cr}}{A}, \quad '
            r'\lambda = \frac{KL}{r}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'σcr = Pcr / A、λ = K·L / r、r = √(I/A)',
        caption: '座屈応力と細長比',
      ),
    ],
    symbols: [
      HelpSymbol('Pcr', '座屈荷重（オイラー荷重）', 'N'),
      HelpSymbol('E', '縦弾性係数', 'MPa'),
      HelpSymbol('I', '最小の断面二次モーメント', 'mm⁴'),
      HelpSymbol('K', '有効長さ係数、支持条件で決まる'),
      HelpSymbol('L', '支持されていない長さ', 'mm'),
      HelpSymbol('λ', '細長比'),
    ],
    notes: [
      '断面の最小の I を使ってください。柱は、こちらが曲がると思っていた向きに'
          '関わらず、最も弱い軸まわりに座屈します。',
      '理論上の K は両端ピンで 1.0、両端固定で 0.5、一端固定・一端ピンで 0.7、'
          '一端固定・一端自由で 2.0 です。実際の端部は完全な固定にはならないため、'
          '設計規格は理論値より大きな値を推奨します。',
      'オイラー式は細長い柱にのみ適用できます。σcr が降伏強さの約半分を超えると'
          '非弾性座屈に移行し、ジョンソンの放物線式や規格の柱曲線を使うべきです。',
      '完全にまっすぐで荷重が中心に作用する柱を前提とします。実際の初期曲がりや'
          '偏心は耐力を下げ、規格の安全率はそれを見込んだものです。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 13',
      'AISC Steel Construction Manual, ch. E',
    ],
    diagram: 'images/buckling/icon_buckling_pinned_pinned.png',
  ),
  120: ToolHelp(
    summary: 'ボルトまたはリベットの重ね継手が、板と締結具において壊れる 3 つの'
        '経路：ボルトのせん断、板の支圧によるつぶれ、そして端部までの'
        'せん断破断（引きちぎれ）。継手の強さは最も弱い経路で決まるため、'
        '3 つを同時に確認します。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{P}{n\,m\,\frac{\pi d^2}{4}}',
        plain: 'τ = P / (n·m·π·d²/4)',
        caption: 'ボルトのせん断、m = 1 は一面せん断、2 は二面せん断',
      ),
      HelpFormula(
        tex: r'\sigma_b = \frac{P}{n\,d\,t}',
        plain: 'σb = P / (n·d·t)',
        caption: '投影面積に基づく支圧応力',
      ),
      HelpFormula(
        tex: r'\tau_{to} = \frac{P}{2n\left(e-\frac{d}{2}\right)t}',
        plain: 'τto = P / [2·n·(e − d/2)·t]',
        caption: '端部までの 2 面に沿った引きちぎれ',
      ),
    ],
    symbols: [
      HelpSymbol('P', '継手に作用する荷重', 'N'),
      HelpSymbol('n', '締結具の本数'),
      HelpSymbol('m', '締結具 1 本あたりのせん断面数：1 または 2'),
      HelpSymbol('d', '締結具の直径', 'mm'),
      HelpSymbol('t', '最も薄い被締結板の厚さ', 'mm'),
      HelpSymbol('e', '縁端距離、穴中心から自由端まで', 'mm'),
    ],
    notes: [
      '支圧型継手です。荷重は摩擦ではなく、締結具が穴に支圧することで伝わります。'
          'すべり耐力型継手は軸力と摩擦で設計され、ここでの値は支配しません。',
      '荷重が締結具に均等に分配されることを前提とします。短くまとまった'
          'ボルト群では妥当ですが、長く並んだ列では楽観的で、端のボルトに'
          'より大きな力がかかります。',
      '板の有効断面の引張破断は 4 つめの破壊経路であり、ここでは確認しません。'
          '穴の面積を差し引いて別途検討してください。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'AISC Steel Construction Manual, ch. J3',
    ],
  ),
  121: ToolHelp(
    summary: '同じ点に作用する軸力、曲げ、ねじりを 1 つの垂直応力と 1 つの'
        'せん断応力にまとめます。すべてが線形弾性である限り重ね合わせが成り立ち、'
        '得られたこの 2 つが強度理論の入力になります。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{P}{A} + \frac{Mc}{I}',
        plain: 'σ = P/A + M·c/I',
        caption: '垂直応力：軸力と曲げ',
      ),
      HelpFormula(
        tex: r'\tau = \frac{Tr}{J}',
        plain: 'τ = T·r / J',
        caption: 'ねじりによるせん断応力',
      ),
    ],
    symbols: [
      HelpSymbol('P', '軸方向力、引張を正とする', 'N'),
      HelpSymbol('A', '断面積', 'mm²'),
      HelpSymbol('M', '曲げモーメント', 'N·mm'),
      HelpSymbol('c', '中立軸から着目点までの距離', 'mm'),
      HelpSymbol('I', '曲げ軸まわりの断面二次モーメント', 'mm⁴'),
      HelpSymbol('T', 'ねじりモーメント', 'N·mm'),
      HelpSymbol('r', '着目点までの半径', 'mm'),
      HelpSymbol('J', '断面二次極モーメント', 'mm⁴'),
    ],
    notes: [
      '重ね合わせには線形弾性と微小変位が必要です。細長い部材が軸圧縮を受けると'
          'たわみ自体が付加曲げモーメントを生じますが（P–δ 効果）、'
          'ここでは考慮していません。',
      '曲げに伴う横方向せん断応力は別扱いで、中立軸で最大になります。'
          'そこでは曲げ応力が零です。最外縁だけでなく両方の位置を確認してください。',
      'mm と MPa に合わせて、モーメントは N·mm で入力します。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 8',
      'Shigley, Mechanical Engineering Design, ch. 3',
    ],
  ),

  102: ToolHelp(
    summary: '代表的な断面形状について、図心軸まわりの断面二次モーメント。'
        'I は断面の曲げ剛性と、与えられたモーメントでの応力の大きさを決める'
        '幾何量であり、I 形鋼が効率的で平鋼がそうでない理由もここにあります。',
    formulas: [
      HelpFormula(
        tex: r'I_x = \frac{bh^3}{12}, \quad I_y = \frac{hb^3}{12}',
        plain: 'Ix = b·h³/12、Iy = h·b³/12',
        caption: '長方形、図心まわり',
      ),
      HelpFormula(
        tex: r'I = \frac{\pi d^4}{64}',
        plain: 'I = π·d⁴/64',
        caption: '中実円',
      ),
      HelpFormula(
        tex: r'I = I_c + Ad^2',
        plain: 'I = Ic + A·d²',
        caption: '平行軸の定理、別の軸へ移すとき',
      ),
    ],
    symbols: [
      HelpSymbol('I', '断面二次モーメント', 'mm⁴'),
      HelpSymbol('b, h', '幅と高さ', 'mm'),
      HelpSymbol('A', '面積', 'mm²'),
      HelpSymbol('d', '2 つの平行軸間の距離', 'mm'),
    ],
    notes: [
      '高さの項は 3 乗なので、幅より高さのほうがはるかに効率よく剛性を上げます。'
          'h を 2 倍にすると Ix は 8 倍、b を 2 倍にしても 2 倍にしかなりません。',
      '平行軸の定理は図心を通る軸とそれに平行な軸の間でのみ使えます。'
          '図心を通らない 2 軸の間で移すときは、いったん図心を経由してください。',
      'ここでの値は面積の二次モーメント（mm⁴）であり、'
          '動力学で使う kg·m² の慣性モーメントではありません。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'Gere & Goodno, Mechanics of Materials, ch. 12',
    ],
    diagram: 'images/cross_section/icon_cs_rectangle.png',
  ),
  117: ToolHelp(
    summary: '断面の図心、面積、断面二次モーメント、およびそれらから導かれる'
        '断面係数と断面二次半径。はりや柱の計算に必ず必要になる量であり、'
        'まとめて求めることで互いに矛盾しないようにしています。',
    formulas: [
      HelpFormula(
        tex: r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'ȳ = Σ(Ai·ȳi) / Σ Ai',
        caption: '組立て断面の図心',
      ),
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c、r = √(I / A)',
        caption: '断面係数と断面二次半径',
      ),
    ],
    symbols: [
      HelpSymbol('ȳ', '基準端から測った図心位置', 'mm'),
      HelpSymbol('I', '図心軸まわりの断面二次モーメント', 'mm⁴'),
      HelpSymbol('S', '断面係数', 'mm³'),
      HelpSymbol('c', '図心から最外縁までの距離', 'mm'),
      HelpSymbol('r', '断面二次半径', 'mm'),
    ],
    notes: [
      '断面係数は強度からはりを決めるときに（σ = M/S）、'
          '断面二次半径は安定から柱を決めるときに（λ = KL/r）使います。',
      '曲げ軸に対して対称でない断面では c が上下で異なるため断面係数が 2 つになり、'
          '小さいほうが設計を支配します。',
      '素の寸法から求めた値には圧延の隅肉や溶接金属が含まれないため、'
          '形鋼の公表値より数パーセント小さくなります。カタログ形状であれば'
          '標準断面ライブラリを使ってください。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix A',
      'AISC Steel Construction Manual, Part 1',
    ],
  ),
  104: ToolHelp(
    summary: 'はり断面の任意の高さにおける曲げ応力。応力は中立軸で零、'
        '最外縁で最大となるよう直線的に変化するため、中立軸付近の材料は'
        'ほとんど荷重を負担せず、効率のよい断面は面積を中立軸から遠くに配置します。',
    formulas: [
      HelpFormula(
        tex: r'\sigma = \frac{My}{I}',
        plain: 'σ = M·y / I',
        caption: '中立軸から y の位置での曲げ応力',
      ),
      HelpFormula(
        tex: r'\sigma_{\max} = \frac{Mc}{I} = \frac{M}{S}',
        plain: 'σmax = M·c / I = M / S',
        caption: '最外縁において',
      ),
    ],
    symbols: [
      HelpSymbol('σ', '曲げ応力、引張を正とする', 'MPa'),
      HelpSymbol('M', 'その断面の曲げモーメント', 'N·mm'),
      HelpSymbol('y', '中立軸からの距離', 'mm'),
      HelpSymbol('I', '曲げ軸まわりの断面二次モーメント', 'mm⁴'),
      HelpSymbol('c', '最外縁までの距離', 'mm'),
    ],
    notes: [
      'オイラー・ベルヌーイ理論：平面保持、線形弾性、まっすぐな等断面はりを前提とします。',
      '中立軸が図心を通るのは、均質断面の純曲げの場合だけです。軸力が加わると'
          '中立軸は移動し、異種材料の断面には換算断面法が必要になります。',
      '主軸でない軸まわりの曲げは非対称曲げであり、この一軸の式は適用できません。',
      'mm と MPa に合わせて、M は N·mm で入力します。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 6',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
    diagram: 'images/icon_beam_bending.png',
  ),
  113: ToolHelp(
    summary: 'はり断面に生じる横方向せん断応力。曲げ応力が零になる中立軸で'
        '最大になるため、両者は別々の高さで確認する必要があります。'
        '短くて背の高いはりや薄いウェブで特に重要で、'
        'そうした場合はせん断が曲げより支配的になることがあります。',
    formulas: [
      HelpFormula(
        tex: r'\tau = \frac{VQ}{It}',
        plain: 'τ = V·Q / (I·t)',
        caption: 'Q をとった高さでのせん断応力',
      ),
      HelpFormula(
        tex: r'\tau_{\max} = \frac{3V}{2A} \;\text{(rectangle)}, \quad '
            r'\frac{4V}{3A} \;\text{(circle)}',
        plain: 'τmax = 3V/(2A) 長方形、4V/(3A) 円形',
        caption: '代表的な中実断面での最大値',
      ),
    ],
    symbols: [
      HelpSymbol('τ', '横方向せん断応力', 'MPa'),
      HelpSymbol('V', 'その断面のせん断力', 'N'),
      HelpSymbol('Q', '切断位置より外側の面積の断面一次モーメント', 'mm³'),
      HelpSymbol('I', '断面全体の断面二次モーメント', 'mm⁴'),
      HelpSymbol('t', '切断位置における断面の幅', 'mm'),
    ],
    notes: [
      'Q は着目する高さの片側だけの面積について、中立軸まわりにとった'
          '一次モーメントです。中立軸で最大、最外縁で零になります。',
      'この式は幅 t にわたってせん断応力が一様であることを前提とします。'
          '幅の狭いウェブにはよく合いますが、広いフランジでは実際の分布が'
          '幅方向に変化するため合いません。',
      'I 形はりでは、V をウェブ断面積で割る簡便法が厳密解と数パーセントしか'
          '違わず、設計規格もそれを用いています。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, ch. 7',
      'Gere & Goodno, Mechanics of Materials, ch. 5',
    ],
  ),
  105: ToolHelp(
    summary: '代表的な荷重状態における片持ちはりのたわみとたわみ角を、'
        '古典的な閉じた解から求めます。剛性の手早い確認に使えるほか、'
        '重ね合わせでより複雑な荷重を組み立てるのにも使えます。',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{3EI}, \quad '
            r'\theta = \frac{PL^2}{2EI}',
        plain: 'δmax = P·L³/(3·E·I)、θ = P·L²/(2·E·I)',
        caption: '自由端に集中荷重 P',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{wL^4}{8EI}, \quad '
            r'\theta = \frac{wL^3}{6EI}',
        plain: 'δmax = w·L⁴/(8·E·I)、θ = w·L³/(6·E·I)',
        caption: '全長にわたる等分布荷重 w',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'たわみ', 'mm'),
      HelpSymbol('θ', 'たわみ角', 'rad'),
      HelpSymbol('P', '集中荷重', 'N'),
      HelpSymbol('w', '分布荷重', 'N/mm'),
      HelpSymbol('L', '固定端からのスパン', 'mm'),
      HelpSymbol('E·I', '曲げ剛性', 'N·mm²'),
    ],
    notes: [
      'たわみは L³ または L⁴ に比例します。自由端荷重の片持ちはりでスパンを'
          '2 倍にすると 8 倍たわみやすくなり、長さが他のすべてを圧倒します。',
      'せん断変形を無視した微小変形のオイラー・ベルヌーイ理論です。'
          '寸胴な片持ちはり（L/d がおよそ 10 未満）ではせん断項を加えてください。',
      '荷重は重ね合わせられます。複数の荷重が同時に作用する場合は、'
          '状態ごとのたわみを足し合わせてください。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/cantilever_beam/icon_cantilever_beam.png',
  ),
  106: ToolHelp(
    summary: '代表的な荷重状態における単純支持はりのたわみとたわみ角。'
        'ハンドブックが表にしているのと同じ閉じた解で、スパンの手早い確認や、'
        '重ね合わせによる複雑な荷重の組立てに使えます。',
    formulas: [
      HelpFormula(
        tex: r'\delta_{\max} = \frac{PL^3}{48EI}',
        plain: 'δmax = P·L³/(48·E·I)',
        caption: 'スパン中央の集中荷重',
      ),
      HelpFormula(
        tex: r'\delta_{\max} = \frac{5wL^4}{384EI}',
        plain: 'δmax = 5·w·L⁴/(384·E·I)',
        caption: '全長にわたる等分布荷重',
      ),
    ],
    symbols: [
      HelpSymbol('δ', 'たわみ', 'mm'),
      HelpSymbol('P', '集中荷重', 'N'),
      HelpSymbol('w', '分布荷重', 'N/mm'),
      HelpSymbol('L', '支点間スパン', 'mm'),
      HelpSymbol('E·I', '曲げ剛性', 'N·mm²'),
    ],
    notes: [
      '集中荷重が中央から外れると、最大たわみは荷重位置にもスパン中央にも'
          '生じません。ただしスパン中央の値は最大値の約 2.5% 以内なので、'
          'ハンドブックは中央値を載せています。',
      '微小変形理論で、一端ピン・他端ローラのため軸方向拘束はありません。'
          '両端を軸方向に拘束されたはりはたわむにつれて硬くなるため、'
          'この式は変位を過大に見積もります。',
      '使用性の限界は応力ではなくスパンの割合で決まるのが普通で、'
          '床の積載時 L/360 がよく使われます。',
    ],
    references: [
      'Hibbeler, Mechanics of Materials, Appendix C',
      'Roark\'s Formulas for Stress and Strain, Table 8.1',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  401: ToolHelp(
    summary: '集中荷重、全長等分布荷重、またはその両方を受ける単純支持はりの'
        '支点反力、せん断力、曲げモーメント。せん断力図と曲げモーメント図は、'
        'どの断面を確認すべきか、そしてそのとき使う M がいくらかを教えてくれます。',
    formulas: [
      HelpFormula(
        tex: r'\sum F_y = 0, \quad \sum M = 0',
        plain: 'ΣFy = 0、ΣM = 0',
        caption: 'つり合い条件、これで 2 つの反力が決まる',
      ),
      HelpFormula(
        tex: r'V(x) = R_A - \int_0^x w\,dx, \quad M(x) = \int_0^x V\,dx',
        plain: 'V(x) = RA − ∫w dx、M(x) = ∫V dx',
        caption: 'スパンに沿ったせん断力とモーメント',
      ),
      HelpFormula(
        tex: r'M_{\max} = \frac{wL^2}{8} \;\text{(UDL)}, \quad '
            r'\frac{PL}{4} \;\text{(central point load)}',
        plain: 'Mmax = w·L²/8（等分布）、P·L/4（中央集中荷重）',
      ),
    ],
    symbols: [
      HelpSymbol('RA, RB', '支点反力', 'N'),
      HelpSymbol('V', 'せん断力', 'N'),
      HelpSymbol('M', '曲げモーメント', 'N·mm'),
      HelpSymbol('w', '等分布荷重', 'N/mm'),
      HelpSymbol('L', 'スパン', 'mm'),
    ],
    notes: [
      '静定の場合のみ：一端ピン、他端ローラです。支点が 3 つある場合や'
          '両端固定の場合は不静定となり、つり合いに加えて適合条件が必要です。',
      'モーメントはせん断力が零を横切る位置で最大になります。'
          'そこが設計すべき断面で、荷重が中央から外れていればスパン中央ではありません。',
      '自重は分布荷重に加えないかぎり含まれません。',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 4',
      'Gere & Goodno, Mechanics of Materials, ch. 4',
    ],
    diagram: 'images/simple_beam/icon_simple_beam.png',
  ),
  400: ToolHelp(
    summary: '平面内の共点力を 1 つの合力にまとめ、その大きさと向きを求めます。'
        'ほとんどの静力学の問題における最初の一歩：複数の力を、'
        '同じはたらきをする 1 つの力に置き換えます。',
    formulas: [
      HelpFormula(
        tex: r'R_x = \sum F_i\cos\theta_i, \quad R_y = \sum F_i\sin\theta_i',
        plain: 'Rx = Σ Fi·cosθi、Ry = Σ Fi·sinθi',
        caption: '成分',
      ),
      HelpFormula(
        tex: r'R = \sqrt{R_x^2+R_y^2}, \quad '
            r'\theta_R = \operatorname{atan2}(R_y, R_x)',
        plain: 'R = √(Rx² + Ry²)、θR = atan2(Ry, Rx)',
        caption: '大きさと向き',
      ),
    ],
    symbols: [
      HelpSymbol('F', '各力の大きさ', 'N'),
      HelpSymbol('θ', '各力の向き、+x 軸から測る', '°'),
      HelpSymbol('R', '合力の大きさ', 'N'),
      HelpSymbol('θR', '合力の向き', '°'),
    ],
    notes: [
      '共点力、つまり作用線がすべて 1 点で交わる場合に限ります。'
          '共点でない力は偶力も生じるため、誤った位置の 1 つの力に'
          '置き換えるとその偶力が失われます。',
      'arctan ではなく atan2 を使うのは象限を正しく出すためです。'
          '素の arctan では 30° と 210° を区別できません。',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 2',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 2',
    ],
  ),
  402: ToolHelp(
    summary: '長方形、円、三角形（穴を含む）から成る図形の図心。'
        '図心は面積の一次モーメントが零になる位置であり、'
        'すべての曲げ計算が基準とする軸です。ここを誤ると'
        'それ以降の応力がすべて誤りになります。',
    formulas: [
      HelpFormula(
        tex: r'\bar{x} = \frac{\sum A_i \bar{x}_i}{\sum A_i}, \quad '
            r'\bar{y} = \frac{\sum A_i \bar{y}_i}{\sum A_i}',
        plain: 'x̄ = Σ(Ai·x̄i)/ΣAi、ȳ = Σ(Ai·ȳi)/ΣAi',
        caption: '面積で重み付けした平均',
      ),
    ],
    symbols: [
      HelpSymbol('Ai', '各部分の面積、穴は負とする', 'mm²'),
      HelpSymbol('x̄i, ȳi', '各部分自身の図心', 'mm'),
      HelpSymbol('x̄, ȳ', '全体の図心', 'mm'),
    ],
    notes: [
      '穴は自身の図心をもつ負の面積として扱ってください。'
          'そうすれば式が特別扱いなしにそのまま処理します。',
      '図心は対称軸上に必ず乗るので、計算せずに片方の座標を'
          '書き下せることがよくあります。',
      '図心と重心が一致するのは密度が一様な場合だけです。',
    ],
    references: [
      'Hibbeler, Engineering Mechanics: Statics, ch. 9',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 5',
    ],
  ),
  403: ToolHelp(
    summary: '平面ピン接合トラスを節点法で解きます。各節点はつり合っている'
        '共点力系なので、節点をたどれば全部材力が求まります。'
        '正が引張、負が圧縮です。',
    formulas: [
      HelpFormula(
        tex: r'\sum F_x = 0, \quad \sum F_y = 0 \;\text{at every joint}',
        plain: '各節点で ΣFx = 0 かつ ΣFy = 0',
        caption: 'つり合い、節点あたり 2 式',
      ),
      HelpFormula(
        tex: r'm + r = 2j',
        plain: 'm + r = 2·j',
        caption: '静定性の判定',
      ),
    ],
    symbols: [
      HelpSymbol('m', '部材数'),
      HelpSymbol('r', '支点反力の数'),
      HelpSymbol('j', '節点数'),
    ],
    notes: [
      '摩擦のないピン接合で、荷重は節点にのみ作用することを前提とします。'
          'したがって各部材は純粋な軸力だけを受けます。部材の途中に加わる荷重は'
          '曲げも生じさせ、それはこのモデルの範囲外です。',
      'm + r < 2j は機構で自立できず、m + r > 2j は不静定で、'
          'つり合いに加えて部材剛性が必要です。',
      '静定トラスでも形状が悪ければ不安定になり得ます（たとえば 3 つの反力が'
          '一直線に並ぶ場合）。本数の判定は必要条件であって十分条件ではありません。',
      '圧縮材は座屈の確認も必要ですが、ここでは行いません。',
    ],
    references: [
      'Hibbeler, Structural Analysis, ch. 3',
      'Beer & Johnston, Vector Mechanics for Engineers, ch. 6',
    ],
  ),
  200: ToolHelp(
    summary: '等方性材料に対する三次元の一般化フックの法則。ある方向の応力は'
        'ポアソン比を通じて他の 2 方向にひずみを生じさせるため、'
        '6 つの成分は互いに連成しており、個別には扱えません。',
    formulas: [
      HelpFormula(
        tex: r'\varepsilon_x = \frac{1}{E}\left[\sigma_x - '
            r'\nu(\sigma_y+\sigma_z)\right]',
        plain: 'εx = [σx − ν(σy + σz)] / E',
        caption: '垂直ひずみ、3 式のうちの 1 つ',
      ),
      HelpFormula(
        tex: r'\gamma_{xy} = \frac{\tau_{xy}}{G}, \quad '
            r'G = \frac{E}{2(1+\nu)}',
        plain: 'γxy = τxy / G、G = E / [2(1 + ν)]',
        caption: 'せん断ひずみと弾性係数の関係',
      ),
    ],
    symbols: [
      HelpSymbol('ε', '垂直ひずみ'),
      HelpSymbol('γ', '工学せん断ひずみ'),
      HelpSymbol('σ, τ', '垂直応力とせん断応力', 'MPa'),
      HelpSymbol('E', '縦弾性係数', 'MPa'),
      HelpSymbol('ν', 'ポアソン比'),
      HelpSymbol('G', '横弾性係数', 'MPa'),
    ],
    notes: [
      '等方・均質・線形弾性の材料に適用できます。複合材料、'
          '強い集合組織をもつ圧延板、木材はいずれも該当しません。',
      '等方性材料では E、G、ν のうち独立なのは 2 つだけで、残り 1 つは従属します。'
          '3 つとも矛盾する値を入力すると、静かに誤った答えが出ます。',
      '熱力学的な安定条件から ν は −1 と 0.5 の間に入ります。実際の金属は'
          '0.3 前後で、0.5 は非圧縮を意味し、ゴムがそれに近づきます。',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Boresi & Schmidt, Advanced Mechanics of Materials, ch. 3',
    ],
  ),
  201: ToolHelp(
    summary: '完全な三次元応力状態と、それが生じさせるひずみ状態との間を'
        '双方向に換算します。ひずみから応力を求める形は有限要素の'
        '後処理に必要です。メッシュが与えるのはひずみで、'
        '判定基準が求めるのは応力だからです。',
    formulas: [
      HelpFormula(
        tex: r'\sigma_x = \frac{E}{(1+\nu)(1-2\nu)}\left[(1-\nu)'
            r'\varepsilon_x + \nu(\varepsilon_y+\varepsilon_z)\right]',
        plain: 'σx = E/[(1+ν)(1−2ν)] · [(1−ν)εx + ν(εy + εz)]',
        caption: 'ひずみから応力へ',
      ),
      HelpFormula(
        tex: r'\tau_{xy} = G\gamma_{xy}',
        plain: 'τxy = G · γxy',
        caption: 'せん断は連成しないまま',
      ),
    ],
    symbols: [
      HelpSymbol('σ, τ', '垂直応力とせん断応力', 'MPa'),
      HelpSymbol('ε, γ', '垂直ひずみと工学せん断ひずみ'),
      HelpSymbol('E', '縦弾性係数', 'MPa'),
      HelpSymbol('ν', 'ポアソン比'),
    ],
    notes: [
      'ひずみから応力を求める形は ν が 0.5 に近づくと発散します。'
          '分母の (1 − 2ν) が零に近づくためで、非圧縮材料では'
          '与えられたひずみに対する静水圧が一意に定まらないからです。'
          'ほぼ非圧縮の材料には混合定式化が必要になります。',
      '工学せん断ひずみ γ はテンソルせん断ひずみの 2 倍です。'
          '2 つの流儀を混同すると、見落としやすい 2 倍の誤りになります。',
    ],
    references: [
      'Timoshenko & Goodier, Theory of Elasticity, ch. 1',
      'Sadd, Elasticity: Theory, Applications and Numerics, ch. 4',
    ],
  ),
  305: ToolHelp(
    summary: '繊維と母材の物性から一方向層の剛性と密度を見積もります。'
        '繊維方向では 2 相が同じひずみを受けるため剛性が体積で平均され、'
        '直角方向では荷重を分担するためコンプライアンスが平均されます。'
        '横方向剛性がはるかに低いのはそのためです。',
    formulas: [
      HelpFormula(
        tex: r'E_1 = E_f V_f + E_m(1-V_f)',
        plain: 'E1 = Ef·Vf + Em·(1 − Vf)',
        caption: '繊維方向——複合則',
      ),
      HelpFormula(
        tex: r'\frac{1}{E_2} = \frac{V_f}{E_f} + \frac{1-V_f}{E_m}',
        plain: '1/E2 = Vf/Ef + (1 − Vf)/Em',
        caption: '直角方向——逆複合則',
      ),
      HelpFormula(
        tex: r'\nu_{12} = \nu_f V_f + \nu_m(1-V_f)',
        plain: 'ν12 = νf·Vf + νm·(1 − Vf)',
        caption: '主ポアソン比',
      ),
    ],
    symbols: [
      HelpSymbol('E1', '繊維方向の剛性', 'MPa'),
      HelpSymbol('E2', '繊維直角方向の剛性', 'MPa'),
      HelpSymbol('Vf', '繊維体積含有率'),
      HelpSymbol('Ef, Em', '繊維と母材の弾性係数', 'MPa'),
    ],
    notes: [
      'E1 は信頼できますが、E2 の逆複合則は楽観的で、実測値は通常これを下回ります。'
          '横方向剛性が重要なときは Halpin–Tsai 式が標準的な改良法です。',
      '重量分率ではなく体積分率です。供給者は重量分率で示すことが多いので、'
          '2 つの密度を使って換算してから使ってください。',
      'よく含浸された積層板でも実用上の Vf は 0.65 程度が上限です。'
          'それ以上では繊維をぬらす母材が足りません。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 3',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 3',
    ],
    diagram: 'images/lamina.png',
  ),
  301: ToolHelp(
    summary: '直交異方性層の 4 つの独立な工学定数——2 つの弾性係数、'
        'せん断弾性係数、ポアソン比——と、それらが構成するコンプライアンス行列。'
        'すべての積層板計算はここから始まります。',
    formulas: [
      HelpFormula(
        tex: r'\frac{\nu_{12}}{E_1} = \frac{\nu_{21}}{E_2}',
        plain: 'ν12 / E1 = ν21 / E2',
        caption: '相反関係、これがコンプライアンス行列の対称性を保証する',
      ),
      HelpFormula(
        tex: r'Q_{11} = \frac{E_1}{1-\nu_{12}\nu_{21}}, \quad '
            r'Q_{22} = \frac{E_2}{1-\nu_{12}\nu_{21}}, \quad Q_{66} = G_{12}',
        plain: 'Q11 = E1/(1 − ν12·ν21)、Q22 = E2/(1 − ν12·ν21)、Q66 = G12',
        caption: '低減剛性',
      ),
    ],
    symbols: [
      HelpSymbol('E1, E2', '繊維方向と直角方向の弾性係数', 'MPa'),
      HelpSymbol('G12', '面内せん断弾性係数', 'MPa'),
      HelpSymbol('ν12', '主ポアソン比'),
      HelpSymbol('Q', '低減剛性行列の各成分', 'MPa'),
    ],
    notes: [
      '平面応力では独立な定数は 4 つだけで、ν21 は相反関係から決まります。'
          '別に測定した合わない ν21 を入力すると行列が非対称になり、'
          '物理的に成立しなくなります。',
      'ν12 は方向 1 の荷重によって生じる方向 2 の縮みです。'
          '添字の順序は複合材料で最も混同されやすい点で、逆の流儀の教科書もあります。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 4',
    ],
    diagram: 'images/lamina.png',
  ),
  300: ToolHelp(
    summary: '単層の応力とひずみを、材料主軸または回転させた座標系で求めます。'
        '単層は繊維方向のほうが直角方向よりはるかに剛いため、回転は'
        '数値を回すだけでは済みません。斜め層では垂直応力と'
        'せん断ひずみが連成します。',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}\sigma_1\\\sigma_2\\\tau_{12}\end{bmatrix} = '
            r'[Q]\begin{bmatrix}\varepsilon_1\\\varepsilon_2\\'
            r'\gamma_{12}\end{bmatrix}',
        plain: '{σ1, σ2, τ12} = [Q] · {ε1, ε2, γ12}',
        caption: '材料主軸系において',
      ),
      HelpFormula(
        tex: r'[\bar{Q}] = [T]^{-1}[Q][T]^{-T}',
        plain: '[Q̄] = [T]⁻¹ [Q] [T]⁻ᵀ',
        caption: '積層板座標系へ変換',
      ),
    ],
    symbols: [
      HelpSymbol('σ1, σ2', '繊維方向と直角方向の応力', 'MPa'),
      HelpSymbol('τ12', '面内せん断応力', 'MPa'),
      HelpSymbol('[Q]', '低減剛性行列', 'MPa'),
      HelpSymbol('θ', '積層板 x 軸からの層角度', '°'),
    ],
    notes: [
      '層内は平面応力として扱い、板厚方向の応力は無視します。'
          '薄い積層板の内部では妥当ですが、層間はく離が始まる自由端では成り立ちません。',
      'θ が 0° または 90° 以外であれば変換後の行列に非零の Q̄16、Q̄26 が現れます。'
          'これがせん断・伸び連成であり、数値上の見かけではなく実在の効果です。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 5',
    ],
    diagram: 'images/lamina.png',
  ),
  302: ToolHelp(
    summary: '古典積層理論：各層を組み立てて A、B、D 行列を作り、'
        '面内力とモーメントを中央面ひずみと曲率に結び付けます。'
        '積み重ねた層を、挙動が予測できる構造材料に変えるのがこの理論です。',
    formulas: [
      HelpFormula(
        tex: r'\begin{bmatrix}N\\M\end{bmatrix} = '
            r'\begin{bmatrix}A & B\\B & D\end{bmatrix}'
            r'\begin{bmatrix}\varepsilon^0\\\kappa\end{bmatrix}',
        plain: '{N, M} = [[A, B], [B, D]] · {ε⁰, κ}',
        caption: '積層板の構成関係',
      ),
      HelpFormula(
        tex: r'A_{ij}=\sum \bar{Q}_{ij}(z_k-z_{k-1}), \quad '
            r'B_{ij}=\tfrac{1}{2}\sum \bar{Q}_{ij}(z_k^2-z_{k-1}^2), \quad '
            r'D_{ij}=\tfrac{1}{3}\sum \bar{Q}_{ij}(z_k^3-z_{k-1}^3)',
        plain: 'Aij = ΣQ̄ij·(zk − zk−1)；Bij = ½ΣQ̄ij·(zk² − zk−1²)；'
            'Dij = ⅓ΣQ̄ij·(zk³ − zk−1³)',
        caption: '面内剛性、連成剛性、曲げ剛性',
      ),
    ],
    symbols: [
      HelpSymbol('N', '単位幅あたりの面内力', 'N/mm'),
      HelpSymbol('M', '単位幅あたりのモーメント', 'N·mm/mm'),
      HelpSymbol('ε⁰', '中央面ひずみ'),
      HelpSymbol('κ', '曲率', '1/mm'),
      HelpSymbol('z', '中央面から測った層境界の高さ', 'mm'),
    ],
    notes: [
      'B が零になるのは、積層構成が中央面に関して対称なときに限ります。'
          'B が零でないと伸びと曲げが連成し、硬化後の冷却で部品が反ります。'
          '実用的な積層板がほぼ必ず対称積層である理由がこれです。',
      '古典積層理論は横せん断を無視するため、厚い積層板や'
          'コアの柔らかいサンドイッチパネルの剛性を過大に評価します。',
      '硬化による残留熱応力は含まれておらず、初層破壊荷重のかなりの割合を'
          '占めることがあります。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  303: ToolHelp(
    summary: '積層板の等価な面内工学定数——積層全体を均質な板として'
        '試験したときに得られるはずの弾性係数です。金属との比較や、'
        '単一材料しか受け付けない解析への入力に便利です。',
    formulas: [
      HelpFormula(
        tex: r'E_x = \frac{1}{h\,a_{11}}, \quad E_y = \frac{1}{h\,a_{22}}, '
            r'\quad G_{xy} = \frac{1}{h\,a_{66}}',
        plain: 'Ex = 1/(h·a11)、Ey = 1/(h·a22)、Gxy = 1/(h·a66)',
        caption: '面内剛性の逆行列 [a] = [A]⁻¹ から',
      ),
      HelpFormula(
        tex: r'\nu_{xy} = -\frac{a_{12}}{a_{11}}',
        plain: 'νxy = −a12 / a11',
      ),
    ],
    symbols: [
      HelpSymbol('Ex, Ey', '等価な面内弾性係数', 'MPa'),
      HelpSymbol('Gxy', '等価な面内せん断弾性係数', 'MPa'),
      HelpSymbol('h', '積層板の全厚', 'mm'),
      HelpSymbol('[a]', 'A 行列の逆行列', 'mm/N'),
    ],
    notes: [
      'これらは面内挙動だけを表します。曲げ剛性は D から決まり、'
          '同じ層でも順序を変えれば A は変わらずとも D は変わります。'
          '積層順序は曲げには効き、伸びには効きません。',
      '対称積層板でのみ意味をもちます。B 行列が零でなければ、'
          'その積層はそもそも均質な板のようにはふるまいません。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 4',
      'Daniel & Ishai, Engineering Mechanics of Composite Materials, ch. 7',
    ],
    diagram: 'images/laminate.png',
  ),
  304: ToolHelp(
    summary: '古典積層理論が省く板厚方向の項を含めた、積層板の三次元等価物性。'
        '部品が厚いとき、面外荷重が効くとき、ソリッド要素の有限要素モデルに'
        '入力するときに必要になります。',
    formulas: [
      HelpFormula(
        tex: r'[C] = [S]^{-1}',
        plain: '[C] = [S]⁻¹',
        caption: '剛性は組み立てたコンプライアンスの逆行列',
      ),
    ],
    symbols: [
      HelpSymbol('[C]', '6×6 剛性行列', 'MPa'),
      HelpSymbol('[S]', '6×6 コンプライアンス行列', '1/MPa'),
      HelpSymbol('E3', '板厚方向の弾性係数', 'MPa'),
      HelpSymbol('G13, G23', '横せん断弾性係数', 'MPa'),
    ],
    notes: [
      '板厚方向の物性は母材が支配するため低く、E1 より 2 桁小さいこともよくあります。'
          '複合材料が降伏ではなく層間はく離で壊れるのはそのためです。',
      '三次元等価物性は積層板を 1 つの均質な異方性固体にならしたものです。'
          '全体剛性には適していますが、自由端の層間応力にはまったく使えず、'
          'それには層ごとのモデルが必要です。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Herakovich, Mechanics of Fibrous Composites, ch. 3',
    ],
    diagram: 'images/laminate.png',
  ),
  306: ToolHelp(
    summary: '組合せ応力を受ける一方向層の初層破壊判定基準。'
        'Tsai–Hill と Tsai–Wu は相互作用を含む二次形式の基準で、'
        '最大応力・最大ひずみ基準は成分ごとに確認し、'
        'どのモードで壊れるかを示します。',
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
        caption: 'Tsai–Wu、引張と圧縮を区別できる',
      ),
    ],
    symbols: [
      HelpSymbol('X', '繊維方向強度', 'MPa'),
      HelpSymbol('Y', '直角方向強度', 'MPa'),
      HelpSymbol('S', '面内せん断強度', 'MPa'),
      HelpSymbol('σ1, σ2, τ12', '材料主軸系での層応力', 'MPa'),
    ],
    notes: [
      'これらが予測するのは初層破壊であって、積層板の最終破壊ではありません。'
          '最初の層が割れた後も積層板はかなりの荷重を担い続けるため、'
          '真の終局荷重には進展破壊解析が必要です。',
      '応力の符号に応じて引張または圧縮の強度を使い分けてください。'
          'Tsai–Hill の素の形は自動ではそうしません。',
      'Tsai–Wu には相互作用項 F12 が必要ですが測定が難しく、'
          'F12 = −½√(F11·F22) がよく使われる妥当な既定値です。',
      'いずれの基準も層が「どのように」壊れたかは示しません。'
          '最大応力基準はそれを示すので、並行して確認する価値があります。',
    ],
    references: [
      'Jones, Mechanics of Composite Materials, ch. 2',
      'Tsai & Wu, "A General Theory of Strength for Anisotropic Materials", '
          'J. Composite Materials, 1971',
    ],
    diagram: 'images/lamina.png',
  ),

  701: ToolHelp(
    summary: '丸線の圧縮コイルばね：ばね指数、曲率と直接せん断を織り込む'
        'Wahl 補正係数、ばね定数、サージング周波数。注目すべきは指数 C で、'
        '4 を下回るとコイリングが難しく、12 を超えるとからみや座屈を起こします。',
    formulas: [
      HelpFormula(
        tex: r'C = \frac{D}{d}, \quad '
            r'K_W = \frac{4C-1}{4C-4} + \frac{0.615}{C}',
        plain: 'C = D/d、KW = (4C − 1)/(4C − 4) + 0.615/C',
        caption: 'ばね指数と Wahl 係数',
      ),
      HelpFormula(
        tex: r'\tau = K_W \frac{8FD}{\pi d^3}',
        plain: 'τ = KW · 8·F·D / (π·d³)',
        caption: '補正後の線材せん断応力',
      ),
      HelpFormula(
        tex: r'k = \frac{Gd^4}{8D^3N_a}',
        plain: 'k = G·d⁴ / (8·D³·Na)',
        caption: 'ばね定数',
      ),
    ],
    symbols: [
      HelpSymbol('d', '線径', 'mm'),
      HelpSymbol('D', 'コイル平均径', 'mm'),
      HelpSymbol('C', 'ばね指数'),
      HelpSymbol('Na', '有効巻数'),
      HelpSymbol('G', '線材の横弾性係数', 'MPa'),
      HelpSymbol('k', 'ばね定数', 'N/mm'),
    ],
    notes: [
      'D は平均径であり、外径から線径 1 本分を引いた値です。'
          '外径を使うとばね定数をはっきり過大に見積もります。',
      '有効巻数は総巻数より少なくなります。研削した閉じ端では約 2 巻分、'
          '開き端ではほとんど減りません。',
      '使用周波数はサージング周波数から十分に離してください——'
          'バルブスプリングでは 15〜20 倍が目安です。サージングは'
          'ばねを伝わる波であって、剛体モードではありません。',
      '線材の強度は線径に強く依存します。同じ材質でも細い線のほうがはるかに強くなります。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 10',
      'Wahl, Mechanical Springs',
    ],
  ),
  702: ToolHelp(
    summary: '圧力角 20°・並歯のインボリュート平歯車対の幾何——ピッチ円直径、'
        '中心距離、歯数比——に加えて、Lewis の曲げ応力と簡易的な面圧の推定値。'
        '初期検討のためのもので、AGMA の強度計算ではありません。',
    formulas: [
      HelpFormula(
        tex: r'd = mN, \quad C = \frac{d_1+d_2}{2}, \quad '
            r'i = \frac{N_2}{N_1}',
        plain: 'd = m·N、C = (d1 + d2)/2、i = N2/N1',
        caption: 'ピッチ円直径、中心距離、歯数比',
      ),
      HelpFormula(
        tex: r'\sigma = \frac{W_t}{b\,m\,Y}',
        plain: 'σ = Wt / (b·m·Y)',
        caption: '歯元の Lewis 曲げ応力',
      ),
    ],
    symbols: [
      HelpSymbol('m', 'モジュール', 'mm'),
      HelpSymbol('N', '歯数'),
      HelpSymbol('d', 'ピッチ円直径', 'mm'),
      HelpSymbol('Wt', '接線方向の歯面荷重', 'N'),
      HelpSymbol('b', '歯幅', 'mm'),
      HelpSymbol('Y', 'Lewis の歯形係数'),
    ],
    notes: [
      'Lewis の式は 1 枚の歯を静的な片持ちはりとして扱います。'
          '歯元すみ肉の応力集中、動荷重、複数歯の荷重分担、'
          'かみ合い誤差はいずれも考慮されません。AGMA 2001 はそれらを'
          '明示的な係数として扱っており、実際の強度計算には欠かせません。',
      '圧力角 20°・並歯のピニオンは 17 枚を下回ると切下げを生じます。'
          'それより少ない歯数には転位が必要です。',
      '面圧（ヘルツ応力）は通常、歯面の耐久性を支配し、'
          '曲げ応力は歯の折損を支配します。壊れ方が違うため、両方の確認が必要です。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 13–14',
      'ANSI/AGMA 2001-D04',
    ],
  ),
  703: ToolHelp(
    summary: '変動曲げと定常ねじりが組み合わさった場合の軸の最小直径を、'
        'せん断ひずみエネルギー説と修正グッドマン線図によって求めます。'
        '曲げが完全両振り、トルクが一定という最も一般的な回転軸の場合に対する'
        '標準的な軸径算定式です。',
    formulas: [
      HelpFormula(
        tex: r'd = \left(\frac{16n}{\pi}\left\{\frac{1}{S_e}\left[4(K_f '
            r'M_a)^2 + 3(K_{fs}T_a)^2\right]^{1/2} + \frac{1}{S_{ut}}'
            r'\left[4(K_f M_m)^2 + 3(K_{fs}T_m)^2\right]^{1/2}\right\}'
            r'\right)^{1/3}',
        plain: 'd = { (16n/π) · [ (1/Se)·√(4(Kf·Ma)² + 3(Kfs·Ta)²) '
            '+ (1/Sut)·√(4(Kf·Mm)² + 3(Kfs·Tm)²) ] }^(1/3)',
        caption: 'DE–グッドマンによる軸径',
      ),
    ],
    symbols: [
      HelpSymbol('Ma, Mm', '変動曲げモーメントと平均曲げモーメント', 'N·m'),
      HelpSymbol('Ta, Tm', '変動トルクと平均トルク', 'N·m'),
      HelpSymbol('Se', '修正後の疲労限度', 'MPa'),
      HelpSymbol('Sut', '引張強さ', 'MPa'),
      HelpSymbol('Kf, Kfs', '疲労切欠き係数'),
      HelpSymbol('n', '設計係数'),
    ],
    notes: [
      '一定の横荷重を受ける回転軸では、曲げは完全両振りになります。'
          'Ma が曲げモーメントの全量で、Mm は零です。一定駆動によるトルクは逆で、'
          'Tm だけになります。',
      'Kf と Kfs は危険部位における疲労係数で、通常は段付きすみ肉、キー溝、'
          'しまりばめ部です。1 のままにするのは楽観的で、鋭い段付きなら容易に 2 になります。',
      '疲労強度に対する寸法決定のみです。たわみ、軸受位置での傾き、'
          '危険速度も確認してください——これを満たしても使えない軸はあり得ます。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 7',
      'ANSI/ASME B106.1M, Design of Transmission Shafting',
    ],
  ),
  704: ToolHelp(
    summary: '転がり軸受の基本定格寿命：同一仕様の軸受のうち 90% が到達する回転数。'
        '指数の効果で寿命は荷重に極めて敏感になり、荷重を半分にすると'
        '玉軸受の寿命は 8 倍になります。',
    formulas: [
      HelpFormula(
        tex: r'L_{10} = \left(\frac{C}{P}\right)^{p}',
        plain: 'L10 = (C/P)^p、玉軸受 p = 3、ころ軸受 p = 10/3',
        caption: '定格寿命（百万回転）',
      ),
      HelpFormula(
        tex: r'L_{10h} = \frac{10^6 L_{10}}{60n}',
        plain: 'L10h = 10⁶ · L10 / (60·n)',
        caption: '時間への換算',
      ),
    ],
    symbols: [
      HelpSymbol('C', '基本動定格荷重、カタログ値', 'N'),
      HelpSymbol('P', '動等価荷重', 'N'),
      HelpSymbol('n', '回転数', 'rpm'),
      HelpSymbol('L10', '定格寿命', '百万回転'),
    ],
    notes: [
      'L10 は「その時点で 10% が壊れていると見込まれる」という意味であり、'
          '軸受がそれだけもつという意味ではありません。中央寿命は L10 のおよそ 5 倍です。',
      'P は動等価荷重 P = X·Fr + Y·Fa であり、カタログの係数でラジアル分力と'
          'アキシアル分力を合成したものです。スラストがあるときは単なるラジアル荷重ではありません。',
      '基本定格寿命は潤滑、汚染、温度を考慮していません。ISO 281 はそのために'
          '寿命修正係数 a-ISO を導入しており、潤滑不良の軸受は L10 に遠く届かないこともあります。',
      'C は「動」定格荷重でなければなりません。静定格荷重 C0 は静止した軸受の'
          '圧痕を支配する別の値です。',
    ],
    references: [
      'ISO 281, Rolling bearings — Dynamic load ratings and rating life',
      'Shigley, Mechanical Engineering Design, ch. 11',
    ],
  ),
  705: ToolHelp(
    summary: 'オープンベルト（またはピッチ円直径を使うローラチェーン）伝動の幾何：'
        '速度比、ベルト長さ、各プーリの巻付き角。小プーリの巻付き角が、'
        '摩擦伝動のベルトがすべる前に伝えられるトルクを決めます。',
    formulas: [
      HelpFormula(
        tex: r'i = \frac{D_2}{D_1} = \frac{n_1}{n_2}',
        plain: 'i = D2/D1 = n1/n2',
        caption: '速度比',
      ),
      HelpFormula(
        tex: r'L = 2C + \frac{\pi}{2}(D_1+D_2) + \frac{(D_2-D_1)^2}{4C}',
        plain: 'L = 2C + (π/2)(D1 + D2) + (D2 − D1)²/(4C)',
        caption: 'オープンベルトの長さ',
      ),
      HelpFormula(
        tex: r'\theta_1 = \pi - 2\arcsin\frac{D_2-D_1}{2C}',
        plain: 'θ1 = π − 2·arcsin[(D2 − D1)/(2C)]',
        caption: '小プーリの巻付き角',
      ),
    ],
    symbols: [
      HelpSymbol('D1, D2', '小プーリと大プーリのピッチ円直径', 'mm'),
      HelpSymbol('C', '軸間距離', 'mm'),
      HelpSymbol('L', 'ベルト長さ', 'mm'),
      HelpSymbol('θ1', '小プーリの巻付き角', 'rad'),
    ],
    notes: [
      'ベルト長さの式は標準的な近似で、C が (D1 + D2) 程度より大きければ非常に高精度です。',
      '小プーリの巻付き角は 120° 以上を保ってください。それを下回ると'
          '平ベルトや V ベルトは定格能力に達する前にすべり、通常はアイドラで対処します。',
      'ローラチェーンではピッチ円直径を使い、長さは偶数リンクに丸めてください。'
          '奇数リンクはオフセットリンクが必要で、強度が下がります。',
      '幾何のみです。ベルトの伝達能力は断面、速度、メーカ表のサービスファクタで決まります。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 17',
      'ANSI/ASME B29.1, Precision Power Transmission Roller Chains',
    ],
  ),
  706: ToolHelp(
    summary: '目標軸力に達するために必要な締付けトルクを、簡易のトルク–軸力関係式で'
        '求めます。継手を実際に締結しているのは軸力であり、トルクはその間接的な'
        '指標にすぎません——しかも精度の低い指標なので、この値は慎重に扱う必要があります。',
    formulas: [
      HelpFormula(
        tex: r'T = K F_i d',
        plain: 'T = K · Fi · d',
        caption: '目標軸力に対する締付けトルク',
      ),
      HelpFormula(
        tex: r'F_i \approx 0.75 A_t S_p \;\text{(reused)}, \quad '
            r'0.90 A_t S_p \;\text{(permanent)}',
        plain: 'Fi ≈ 0.75·At·Sp（再使用）、0.90·At·Sp（永久締結）',
        caption: '一般的な軸力の目標値',
      ),
    ],
    symbols: [
      HelpSymbol('T', '締付けトルク', 'N·m'),
      HelpSymbol('K', 'トルク係数、無処理鋼で約 0.20'),
      HelpSymbol('Fi', '目標軸力', 'N'),
      HelpSymbol('d', 'ボルト呼び径', 'mm'),
      HelpSymbol('At', '有効断面積', 'mm²'),
      HelpSymbol('Sp', '保証応力', 'MPa'),
    ],
    notes: [
      'K はねじ面と座面の摩擦をまとめたもので、この方法の弱点です。'
          'めっき、潤滑、再使用によって変わり、トルク管理だけでは軸力の'
          'ばらつきが ±25〜30% になるのが普通です。',
      '入力トルクのおよそ 90% は摩擦に消費され、軸力になるのは約 10% です。'
          'したがって摩擦のわずかな変化が軸力の大きな変化になります。',
      '軸力が本当に重要な場合は、締付け後の回転角管理、ボルト伸び測定、'
          '軸力表示ワッシャなどで実測し、トルクに頼らないでください。',
      'は軸部の断面積ではなく有効断面積 At を使ってください。'
          'M10 並目では At が 58 mm² で、呼び径から計算すると 78.5 mm² になります。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 8',
      'Bickford, An Introduction to the Design and Behavior of Bolted Joints',
    ],
  ),
  707: ToolHelp(
    summary: 'すみ肉溶接ののど部に生じるせん断応力。のどは溶接部で最小の断面であり、'
        'したがって破壊面になります。設計実務では継手の荷重の向きにかかわらず、'
        'すみ肉溶接はのど部のせん断で壊れるものとして扱います。',
    formulas: [
      HelpFormula(
        tex: r'a = 0.707\,w, \quad \tau = \frac{F}{a L}',
        plain: 'a = 0.707·w、τ = F / (a·L)',
        caption: 'のど厚とそこに生じるせん断応力',
      ),
    ],
    symbols: [
      HelpSymbol('w', 'すみ肉の脚長', 'mm'),
      HelpSymbol('a', '有効のど厚、等脚すみ肉で 0.707·w', 'mm'),
      HelpSymbol('L', '有効溶接長さ', 'mm'),
      HelpSymbol('F', '溶接群に作用する荷重', 'N'),
    ],
    notes: [
      'すみ肉をすべてのど部のせん断で壊れるとみなすのは標準的な簡略化です。'
          '実際には横方向に荷重を受けるすみ肉は長手方向のものより約 50% 強く、'
          '規格では方向強度係数としてその分を見込むことができます。',
      '0.707 という係数は、のど面が平らな等脚すみ肉に対するものです。'
          '凸ビードや不等脚の溶接ではのど厚が異なります。',
      'ここで扱うのは軸心荷重だけです。偏心荷重は溶接群にねじりや曲げの成分を'
          '加えるため、直接せん断とベクトル合成する必要があります。',
      '溶接金属は通常、母材と同等かやや高い強度なので、'
          '脚長が不足していない限り溶接部が支配することはまれです。',
    ],
    references: [
      'AWS D1.1, Structural Welding Code — Steel',
      'Shigley, Mechanical Engineering Design, ch. 9',
    ],
  ),
  708: ToolHelp(
    summary: '同種材料のハブに中実軸を圧入したときの接触面圧、ハブの周方向応力、'
        '軸の応力。しまりばめは歯車やカップリングを実際に固定する'
        '一般的な方法です——キー溝がないので、応力集中源も生じません。',
    formulas: [
      HelpFormula(
        tex: r'p = \frac{E\delta}{2d}\left[\frac{d_o^2-d^2}{d_o^2}\right]',
        plain: 'p = (E·δ / 2d) · (do² − d²)/do²',
        caption: '接触面圧、両部品が同種材料の場合',
      ),
      HelpFormula(
        tex: r'\sigma_{h} = p\,\frac{d_o^2+d^2}{d_o^2-d^2}, \quad '
            r'\sigma_{\text{shaft}} = -p',
        plain: 'σh = p·(do² + d²)/(do² − d²)、σshaft = −p',
        caption: 'ハブ内面の周方向応力と、一様圧縮を受ける軸',
      ),
    ],
    symbols: [
      HelpSymbol('δ', '直径締めしろ', 'mm'),
      HelpSymbol('d', 'はめあい部の呼び径', 'mm'),
      HelpSymbol('do', 'ハブ外径', 'mm'),
      HelpSymbol('p', '接触面圧', 'MPa'),
      HelpSymbol('E', '縦弾性係数、GPa で入力', 'GPa'),
    ],
    notes: [
      '軸とハブが同種材料であることが、ポアソン比が消える条件です。'
          '異種材料には一般のラメの式が必要で、アルミハブに鋼軸だと'
          '温度が上がるにつれてゆるみます。',
      'ハブ内面の周方向応力は引張であり、継手中で最大の応力です。'
          '薄いハブを割るのは面圧ではなくこれです。',
      '締めしろは呼び値ではなく「はめあい」から決めてください。実際の締めしろは'
          '公差域内で変動し、両端を確認する必要があります——最小はトルク伝達能力、'
          '最大はハブ応力のためです。',
      '組立時に表面粗さがつぶれて有効締めしろが減るため、数マイクロメートルを見込んでください。',
      '継手が伝達できるトルクは μ·p·π·d²·L/2 ですが、ここでは計算しません。'
          '摩擦係数とはめあい長さが必要で、どちらもこのツールの入力にないためです。',
    ],
    references: [
      'Shigley, Mechanical Engineering Design, ch. 3 and 7',
      'ISO 286-1, Geometrical product specifications: ISO code system',
    ],
  ),
  709: ToolHelp(
    summary: 'ロータを 1 つ支持する軸の 1 次危険速度を、ロータのふれまわり振動数と'
        '軸自身の分布質量の影響をダンカレーの式で合成して求めます。'
        '危険速度で運転すると、わずかな不釣合いが大きなたわみを生みます。',
    formulas: [
      HelpFormula(
        tex: r'\omega_r = \sqrt{\frac{k}{m}}, \quad '
            r'\frac{1}{\omega_c^2} = \frac{1}{\omega_r^2} + '
            r'\frac{1}{\omega_s^2}',
        plain: 'ωr = √(k/m)、1/ωc² = 1/ωr² + 1/ωs²',
        caption: 'ロータと軸をダンカレーの式で合成',
      ),
      HelpFormula(
        tex: r'N_c = \frac{60\,\omega_c}{2\pi}',
        plain: 'Nc = 60·ωc / (2π)',
        caption: '危険速度（rpm）',
      ),
    ],
    symbols: [
      HelpSymbol('k', 'ロータ位置での横剛性', 'N/mm'),
      HelpSymbol('m', 'ロータ質量', 'kg'),
      HelpSymbol('ωc', '1 次危険角振動数', 'rad/s'),
      HelpSymbol('Nc', '1 次危険速度', 'rpm'),
    ],
    notes: [
      'ダンカレーの式は常に低めに出るため、得られる危険速度は安全側です。'
          '外すなら有用な方向に外れます。',
      '運転回転数は十分に離してください——1 次危険速度の約 75% 以下、'
          'または約 140% 以上が目安です。昇速時に手早く通過するのは差し支えありません。',
      '軸受は剛と仮定しています。軸受やハウジングが柔らかいと危険速度は下がり、'
          '下がり幅が大きいこともあります。',
      '危険速度を前向きふれまわりと後ろ向きふれまわりに分けるジャイロ効果は含みません。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 10',
      'Shigley, Mechanical Engineering Design, ch. 7',
    ],
  ),
  710: ToolHelp(
    summary: '等断面のまっすぐなはりの横方向固有振動数を、標準的な支持条件について'
        '曲げの 1〜3 次モードで求めます。固有振動数は剛性と質量の比の平方根に比例し、'
        '長さの 2 乗に反比例します。',
    formulas: [
      HelpFormula(
        tex: r'f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}',
        plain: 'fn = (βn·L)² / (2π·L²) · √(E·I / (ρ·A))',
        caption: 'オイラー・ベルヌーイはりの固有振動数',
      ),
    ],
    symbols: [
      HelpSymbol('fn', 'n 次の固有振動数', 'Hz'),
      HelpSymbol('βnL', '支持条件で決まる固有値'),
      HelpSymbol('E·I', '曲げ剛性', 'N·mm²'),
      HelpSymbol('ρ·A', '単位長さあたりの質量', 'kg/m'),
      HelpSymbol('L', 'スパン', 'mm'),
    ],
    notes: [
      'オイラー・ベルヌーイ理論はせん断変形と回転慣性を無視するため、'
          '寸胴なはり（L/d がおよそ 10 未満）や高次モードでは振動数が高めに出ます。'
          'ティモシェンコ理論は両方を補正します。',
      '長さが支配的です。スパンを半分にすると、どの次数の振動数も 4 倍になります。',
      'はり自体に含まれない付加質量——モータ、水の入った配管など——は'
          '振動数を下げますが、ρA に織り込まないかぎり考慮されません。',
      '実際の支持条件は完全固定にも完全ピンにもならず、'
          '真の振動数は 2 つの理想化の間に入ります。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 8',
      'Blevins, Formulas for Natural Frequency and Mode Shape',
    ],
  ),
  711: ToolHelp(
    summary: '丸軸のねじり基本固有振動数。固定端に対してロータ 1 個の場合と、'
        '自由軸にロータ 2 個の場合を扱います。ねじり共振は外からは見えず、'
        'カップリングや歯車の歯の破損の一般的な原因です。',
    formulas: [
      HelpFormula(
        tex: r'k_t = \frac{GJ_p}{L}, \quad '
            r'\omega_n = \sqrt{\frac{k_t}{J_{\text{eff}}}}',
        plain: 'kt = G·Jp / L、ωn = √(kt / Jeff)',
        caption: 'ねじり剛性と固有振動数',
      ),
      HelpFormula(
        tex: r'J_{\text{eff}} = \frac{J_1 J_2}{J_1+J_2}',
        plain: 'Jeff = J1·J2 / (J1 + J2)',
        caption: '自由軸にロータ 2 個の場合の等価慣性モーメント',
      ),
    ],
    symbols: [
      HelpSymbol('kt', 'ねじり剛性', 'N·m/rad'),
      HelpSymbol('G', '横弾性係数', 'MPa'),
      HelpSymbol('Jp', '軸の断面二次極モーメント', 'mm⁴'),
      HelpSymbol('J1, J2', '2 つのロータの慣性モーメント', 'kg·m²'),
    ],
    notes: [
      '軸自身の慣性は無視しています。ロータと同程度の場合は'
          '多質点系（ホルツァー法）の解析が必要です。',
      'Jp は断面の性質で単位は mm⁴、J1 と J2 は質量の慣性モーメントで単位は kg·m² です。'
          '記号が同じ文字なだけの別物で、これを取り違えるのがここで最も多い誤りです。',
      '加振振動数が軸回転数に一致することはまれです。エンジンの発火次数や'
          '歯車のかみ合い振動数はその倍数であり、共振に出会うのは通常そちらです。',
    ],
    references: [
      'Rao, Mechanical Vibrations, ch. 5 and 6',
      'Nestorides, A Handbook on Torsional Vibration',
    ],
  ),
  800: ToolHelp(
    summary: '円管内の流れのレイノルズ数と、それが属する流動状態。'
        'Re は慣性力と粘性力の比であり、流れが整然としているか乱れているかを'
        '決める唯一の指標です。そしてそれが摩擦係数と熱伝達を決めます。',
    formulas: [
      HelpFormula(
        tex: r'Re = \frac{\rho V D}{\mu} = \frac{VD}{\nu}',
        plain: 'Re = ρ·V·D / μ = V·D / ν',
        caption: 'レイノルズ数',
      ),
      HelpFormula(
        tex: r'V = \frac{Q}{A}, \quad A = \frac{\pi D^2}{4}',
        plain: 'V = Q / A、A = π·D²/4',
        caption: '体積流量から流速を求める',
      ),
    ],
    symbols: [
      HelpSymbol('Re', 'レイノルズ数'),
      HelpSymbol('ρ', '密度', 'kg/m³'),
      HelpSymbol('V', '平均流速', 'm/s'),
      HelpSymbol('D', '管内径', 'mm'),
      HelpSymbol('μ', '粘度', 'Pa·s'),
      HelpSymbol('ν', '動粘度、μ/ρ', 'm²/s'),
    ],
    notes: [
      '管内流れでは、約 2300 未満が層流、約 4000 を超えると乱流、'
          'その間が遷移域です。遷移は明確な境界ではなく、入口の乱れや粗さにも依存します。',
      'D は管の内径であり、呼び径ではありません。'
          '配管スケジュールの資料で正しい値を確認してください。',
      '非円形ダクトでは水力直径 4A/P に置き換えます。乱流ではよく合いますが、'
          '層流ではあまり合いません。',
      'V は断面平均流速です。中心軸の流速は層流でその 2 倍、乱流で約 1.2 倍になります。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Munson, Fundamentals of Fluid Mechanics, ch. 8',
    ],
  ),
  801: ToolHelp(
    summary: '満管流れに対するダルシー・ワイスバッハの損失水頭と圧力損失。'
        '摩擦係数はコールブルックの式から求め、継手の損失は速度水頭の'
        '倍数として加えます。配管径の決定と、それに見合うポンプ選定の標準的な方法です。',
    formulas: [
      HelpFormula(
        tex: r'h_f = f\frac{L}{D}\frac{V^2}{2g}',
        plain: 'hf = f · (L/D) · V²/(2g)',
        caption: 'ダルシー・ワイスバッハの摩擦損失水頭',
      ),
      HelpFormula(
        tex: r'\frac{1}{\sqrt{f}} = -2\log_{10}\left(\frac{\varepsilon/D}'
            r'{3.7} + \frac{2.51}{Re\sqrt{f}}\right)',
        plain: '1/√f = −2·log₁₀[ (ε/D)/3.7 + 2.51/(Re·√f) ]',
        caption: 'コールブルックの式、反復で解く',
      ),
      HelpFormula(
        tex: r'h_m = \sum K \frac{V^2}{2g}, \quad \Delta p = \rho g h',
        plain: 'hm = ΣK · V²/(2g)、Δp = ρ·g·h',
        caption: '局所損失と圧力損失',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'ダルシーの摩擦係数'),
      HelpSymbol('L', '管長さ', 'm'),
      HelpSymbol('D', '管内径', 'mm'),
      HelpSymbol('ε', '絶対粗さ', 'mm'),
      HelpSymbol('ΣK', '局所損失係数の合計'),
      HelpSymbol('hf', '損失水頭', 'm'),
    ],
    notes: [
      'ダルシーの摩擦係数はファニングの摩擦係数の 4 倍です。線図や実験式を'
          '使う前にどちらの定義かを確認してください——この 4 倍は古典的な誤りの元です。',
      'コールブルックの式は乱流用です。層流では f = 64/Re を使い、'
          'そこでは粗さにまったく依存しません。',
      '代表的な絶対粗さ：市販鋼管 0.045 mm、引抜き管 0.0015 mm、鋳鉄管 0.26 mm。'
          '古い管は新品よりはるかに粗く、不確かさの大半はここにあります。',
      '非圧縮性流体の定常満管流れを前提とします。半満の重力排水や'
          '圧縮性気体の流れには別の扱いが必要です。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 6',
      'Crane Technical Paper No. 410, Flow of Fluids Through Valves, '
          'Fittings and Pipe',
    ],
  ),
  802: ToolHelp(
    summary: 'ポンプまたはファンに必要な動力：流体が受け取るのは圧力上昇と流量の積で、'
        '原動機が供給しなければならないのはそれを効率で割った値です。'
        '圧力上昇は、ポンプ性能曲線の描き方に合わせて、'
        '送る流体の揚程としても表示します。',
    formulas: [
      HelpFormula(
        tex: r'P_{\text{fluid}} = \Delta p\,Q, \quad '
            r'P_{\text{shaft}} = \frac{\Delta p\,Q}{\eta}',
        plain: 'Pfluid = Δp·Q、Pshaft = Δp·Q / η',
        caption: '水動力と軸動力',
      ),
      HelpFormula(
        tex: r'H = \frac{\Delta p}{\rho g}',
        plain: 'H = Δp / (ρ·g)',
        caption: '圧力上昇を揚程で表す',
      ),
    ],
    symbols: [
      HelpSymbol('Δp', '機械前後の圧力上昇', 'kPa'),
      HelpSymbol('Q', '体積流量', 'm³/s'),
      HelpSymbol('η', '総合効率'),
      HelpSymbol('H', '揚程', 'm'),
    ],
    notes: [
      '揚程は密度に依存しませんが、圧力は依存します。ポンプはどの液体でも'
          '同じ揚程を出し、軽い液体では圧力がその分低くなります。'
          'ポンプ性能曲線がメートル表示なのはこのためです。',
      'ここでの効率は機械全体のものです。電動機効率が別ならば、'
          'さらにそれで割ると電気入力になります。',
      '有効 NPSH がポンプの必要 NPSH を上回っているかも確認してください。'
          'キャビテーションを起こすポンプは、どう動力を選んでも有効に働きません。',
      '空気を送るファンでは、圧力上昇が小さいとき——絶対圧の約 3% 未満——'
          'に限って非圧縮として扱えます。',
    ],
    references: [
      'White, Fluid Mechanics, ch. 11',
      'Hydraulic Institute Standards, ANSI/HI 1.1-1.2',
    ],
  ),
  810: ToolHelp(
    summary: '多層平板壁の定常一次元熱伝導。各層は熱抵抗であり、'
        '両表面の対流熱伝達抵抗と直列に加算されて、'
        '熱通過率、熱流、そして各界面の温度が求まります。',
    formulas: [
      HelpFormula(
        tex: r'R_{\text{cond}} = \frac{t}{k}, \quad '
            r'R_{\text{conv}} = \frac{1}{h}',
        plain: 'Rcond = t/k、Rconv = 1/h',
        caption: '単位面積あたりの熱抵抗',
      ),
      HelpFormula(
        tex: r'U = \frac{1}{\sum R}, \quad q = U\,\Delta T',
        plain: 'U = 1 / ΣR、q = U · ΔT',
        caption: '熱通過率と熱流束',
      ),
    ],
    symbols: [
      HelpSymbol('t', '層の厚さ', 'm'),
      HelpSymbol('k', '熱伝導率', 'W/m·K'),
      HelpSymbol('h', '熱伝達率', 'W/m²·K'),
      HelpSymbol('U', '熱通過率', 'W/m²·K'),
      HelpSymbol('q', '熱流束', 'W/m²'),
    ],
    notes: [
      '平板壁のみで、熱抵抗は t/k として加算されます。円筒殻や球殻では'
          '対数形や逆数形になり、細径の配管に平板の式を使うとはっきり誤ります。',
      '最大の抵抗が支配します。すでに静止空気膜が支配している壁に断熱材を足しても、'
          'k の値から期待されるほどの効果は得られません。',
      '層間の接触熱抵抗は無視していますが、ボルト締結や接着した金属継手では'
          '無視できないことがあります。',
      '定常状態のみです。熱容量を含まないため、壁の応答時間については何も示しません。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'ASHRAE Handbook — Fundamentals, ch. 25',
    ],
  ),
  811: ToolHelp(
    summary: '一様断面の矩形直線フィンの効率を、断熱先端と補正長さを用いて求めます。'
        'フィン効率とは、フィンの温度が長さ方向に下がることを踏まえたうえで、'
        '実際のフィンが理想的な熱流のうちどれだけを達成するかの割合です。',
    formulas: [
      HelpFormula(
        tex: r'm = \sqrt{\frac{2h}{kt}}, \quad L_c = L + \frac{t}{2}',
        plain: 'm = √(2h / (k·t))、Lc = L + t/2',
        caption: 'フィンパラメータと補正長さ',
      ),
      HelpFormula(
        tex: r'\eta_f = \frac{\tanh(mL_c)}{mL_c}',
        plain: 'ηf = tanh(m·Lc) / (m·Lc)',
        caption: 'フィン効率',
      ),
    ],
    symbols: [
      HelpSymbol('h', '熱伝達率', 'W/m²·K'),
      HelpSymbol('k', 'フィンの熱伝導率', 'W/m·K'),
      HelpSymbol('t', 'フィン厚さ', 'm'),
      HelpSymbol('L', 'フィン長さ', 'm'),
      HelpSymbol('ηf', 'フィン効率'),
    ],
    notes: [
      '補正長さは、断熱先端の解で先端からの対流を織り込むための標準的な手法です。'
          'h·t/k が小さいかぎり精度がよく、通常はその条件が満たされます。',
      'フィンが長くなるほど効率は下がります。mLc が約 2 を超えると、'
          '長さを足しても重量が増えるだけで熱はほとんど増えません。'
          'これがフィン高さの実用的な上限です。',
      'フィンが効くのは表面側の抵抗が支配的なときだけです。h がすでに大きい'
          '熱交換器の水側にフィンを付けてもほとんど意味がありません。',
      'フィン内の一次元熱伝導、表面で一様な h、放射なしを前提とします。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 3',
      'Kraus, Aziz & Welty, Extended Surface Heat Transfer',
    ],
  ),
  812: ToolHelp(
    summary: '4 つの出入口温度から求める対数平均温度差と、'
        '所定の熱交換量に必要な伝熱面積。局所の温度差は流路に沿って'
        '直線ではなく指数的に変化するため、熱交換器の平均推進温度差として'
        '正しいのは対数平均温度差です。',
    formulas: [
      HelpFormula(
        tex: r'\Delta T_{lm} = \frac{\Delta T_1 - \Delta T_2}'
            r'{\ln(\Delta T_1/\Delta T_2)}',
        plain: 'ΔTlm = (ΔT1 − ΔT2) / ln(ΔT1/ΔT2)',
        caption: '対数平均温度差',
      ),
      HelpFormula(
        tex: r'A = \frac{Q}{U\,\Delta T_{lm}}',
        plain: 'A = Q / (U · ΔTlm)',
        caption: '所定の熱交換量に必要な面積',
      ),
    ],
    symbols: [
      HelpSymbol('ΔT1, ΔT2', '両端での温度差', 'K'),
      HelpSymbol('U', '熱通過率', 'W/m²·K'),
      HelpSymbol('Q', '熱交換量', 'W'),
      HelpSymbol('A', '伝熱面積', 'm²'),
    ],
    notes: [
      '向流では各入口を相手の出口と組み合わせ、並流では 2 つの入口どうしを'
          '組み合わせます。向流のほうが必ず対数平均温度差が大きく、'
          'したがって装置は小さくなります。冷側出口温度を熱側出口温度より'
          '高くできるのも向流だけです。',
      '多管式や直交流の配置では、標準的な線図から補正係数 F を掛けてください。'
          'F が約 0.8 を下回るのは、流路構成の選び方が適切でない兆候です。',
      '熱交換器全体で U と比熱が一定であること、相変化がないことを前提とします。'
          '片側で凝縮や沸騰がある場合は区間ごとに扱う必要があります。',
      '汚れは時間とともに抵抗を増やします。設計 U には汚れ代を見込まないと、'
          '1 年以内に能力不足になります。',
    ],
    references: [
      'Incropera & DeWitt, Fundamentals of Heat and Mass Transfer, ch. 11',
      'TEMA Standards of the Tubular Exchanger Manufacturers Association',
    ],
  ),
  500: ToolHelp(
    summary: '同じ物理量の単位どうしを換算します——長さ、力、圧力、トルクなど。'
        '定義そのものが厳密であれば換算も厳密で、インチ系の単位はおおむねそうです。'
        '1 インチは 1959 年以来ちょうど 25.4 mm と定められています。',
    formulas: [
      HelpFormula(
        tex: r'v_{\text{target}} = v_{\text{source}} \times '
            r'\frac{f_{\text{source}}}{f_{\text{target}}}',
        plain: '変換後 = 変換前 × (変換前の係数 / 変換後の係数)',
        caption: 'すべての換算は 1 つの SI 基準値を経由する',
      ),
    ],
    symbols: [
      HelpSymbol('f', 'ある単位を SI 基準に換算する係数'),
    ],
    notes: [
      '単位どうしではなく単一の SI 基準を経由して換算すれば、係数は単位ごとに'
          '1 つで済み、組合せごとに必要にはなりません。'
          'そのため n 個の単位の表が自己矛盾を起こしません。',
      '温度は例外です。°C と °F の間には倍率だけでなくオフセットがあるため、'
          '温度「差」の換算は温度そのものとは異なります。',
      'ポンド力とポンド質量は名前の似た別の量です。'
          '換算の前に、その数値がどちらを指しているか確かめてください。',
    ],
    references: [
      'BIPM, The International System of Units (SI), 9th edition',
      'NIST Special Publication 811, Guide for the Use of the SI',
    ],
  ),
  501: ToolHelp(
    summary: '標準的なメートルねじとインチねじの下穴径ときり穴径。'
        '下穴はねじ山のかかり率がおよそ 75% になる材料を残します——'
        'ねじの強度とタップに必要なトルクとの実用的な折り合いです。',
    formulas: [
      HelpFormula(
        tex: r'd_{\text{tap}} \approx D - P',
        plain: '下穴 ≈ D − P（メートルねじ、かかり率およそ 75%）',
        caption: 'おねじ外径からピッチ 1 つ分を引く——一般的な 75% の目安',
      ),
    ],
    symbols: [
      HelpSymbol('D', 'ねじの呼び径（おねじ外径）', 'mm'),
      HelpSymbol('P', 'ピッチ', 'mm'),
    ],
    notes: [
      'D − P は谷の径ではありません。基準の谷の径は D − 1.0825·P であり、'
          '一般的な下穴はあえて浅めのねじ山にしています。',
      'かかり率を 75% から 100% にしても強度は約 5% しか増えず、'
          'タップトルクはおよそ倍になります。ほとんど割に合わず、タップも折れやすくなります。',
      'ねじの強度は、かかり率よりも「かみ合い長さ」に大きく依存します。'
          '軟らかい材料では穴を深くするのではなく、ねじを長くしてください。',
      'きり穴は密・並・粗のはめあい等級から選びます。'
          '組立時に調整が必要でなければ並が既定です。',
      '転造タップは切削タップより大きな下穴が必要です——'
          '材料を削り取るのではなく塑性変形させるためです。',
    ],
    references: [
      'ISO 965-1, ISO general purpose metric screw threads — Tolerances',
      'Machinery\'s Handbook, Threads and Threading',
    ],
  ),
  502: ToolHelp(
    summary: 'ISO 286 の推奨する穴基準はめあいの寸法許容差。'
        'はめあいとは 2 つの公差域の組合せであり、文字が呼び寸法に対する'
        '公差域の位置を、数字がその幅を決めます。'
        'したがって H7/g6 と H7/p6 の違いは精度ではなく位置です。',
    formulas: [
      HelpFormula(
        tex: r'\text{clearance}_{\max} = \text{hole}_{\max} - '
            r'\text{shaft}_{\min}',
        plain: '最大すきま = 穴の最大寸法 − 軸の最小寸法',
        caption: '最小すきまは 穴の最小寸法 − 軸の最大寸法',
      ),
    ],
    symbols: [
      HelpSymbol('H', '穴基準：下の寸法許容差が零'),
      HelpSymbol('IT', '標準公差等級——公差域の幅'),
      HelpSymbol('µm', '寸法許容差はマイクロメートルで表される'),
    ],
    notes: [
      '穴基準が一般的です。穴は寸法の決まった工具で加工し、軸のほうが調整しやすいため、'
          '軸を変えるほうが安く済みます。',
      'すきまが負ならばしめしろです。H7/p6 以上に固いものは圧入となるため、'
          'しまりばめのツールでハブ応力を確認してください。',
      '同じ IT 等級でも寸法が大きくなるほど公差域は広がります——'
          'IT7 は 20 mm で 21 µm、300 mm で 52 µm です。',
      '表にあるのは寸法の限界だけです。実際に軸が入るかどうかは形状にも依存し、'
          '真円度や真直度の誤差がすきまを食いつぶします。',
    ],
    references: [
      'ISO 286-1 and ISO 286-2, Geometrical product specifications',
      'Machinery\'s Handbook, Allowances and Tolerances for Fits',
    ],
  ),
  503: ToolHelp(
    summary: '圧延形鋼の公表寸法と断面性能——AISC の W 形と欧州の IPE、HEB。'
        '公表値には素の形状計算では見えない圧延すみ肉が含まれており、'
        'それは面積と剛性の数パーセントに相当します。',
    formulas: [
      HelpFormula(
        tex: r'S = \frac{I}{c}, \quad r = \sqrt{\frac{I}{A}}',
        plain: 'S = I / c、r = √(I / A)',
        caption: '断面係数と断面二次半径、いずれもここで導出',
      ),
    ],
    symbols: [
      HelpSymbol('A', '断面積', 'mm²'),
      HelpSymbol('Ix, Iy', '強軸・弱軸まわりの断面二次モーメント', 'mm⁴'),
      HelpSymbol('S', '弾性断面係数', 'mm³'),
      HelpSymbol('r', '断面二次半径', 'mm'),
    ],
    notes: [
      '保持しているのは面積と 2 つの断面二次モーメントだけで、S と r はそこから'
          '計算します。そのため転記ミスがあっても互いに矛盾することはありません。',
      '収録しているのは 2 軸対称の I 形断面です。溝形鋼や山形鋼は図心が'
          'せいの中央になく、含まれていません。',
      'これらは弾性の値です。塑性設計では塑性断面係数 Z を使い、'
          'それはより大きく、代表的な I 形で S のおよそ 1.12 倍です。',
      '詳細設計の前に、最新のミル表や規格を確認してください。'
          '断面は改訂や廃止されることがあります。',
    ],
    references: [
      'AISC Steel Construction Manual, Part 1',
      'EN 10365, Hot rolled steel channels, I and H sections',
    ],
  ),
  504: ToolHelp(
    summary: 'ASME B36.10M 鋼管の外径、肉厚、内径。'
        '鋼管は外径を一定にして作られ、同じ継手やねじがどの肉厚にも使えるように'
        'なっています。したがってスケジュールを上げると管が太くなるのではなく、'
        '内径が小さくなります。',
    formulas: [
      HelpFormula(
        tex: r'ID = OD - 2t, \quad A = \frac{\pi\,ID^2}{4}',
        plain: 'ID = OD − 2·t、A = π·ID²/4',
        caption: '内径と流路断面積、いずれもここで導出',
      ),
    ],
    symbols: [
      HelpSymbol('NPS', '呼び径——寸法ではなく名称'),
      HelpSymbol('DN', 'ISO の呼び径、これも名称'),
      HelpSymbol('OD', '外径', 'mm'),
      HelpSymbol('t', '肉厚', 'mm'),
    ],
    notes: [
      'NPS は寸法ではありません。NPS 2 の管は内径も外径も 2 インチではなく、'
          'その数値が外径（インチ）と一致するのは NPS 14 以上だけです。',
      '流れの計算には呼び径ではなく内径を使ってください。NPS 1 では約 5% 違い、'
          '圧力損失の計算では 4 乗で効いてきます。',
      'STD と XS が Sch 40、Sch 80 と一致するのは、それぞれ NPS 10、NPS 8 までです。'
          'それより上では重量クラスの肉厚は増えなくなります。',
      'これらは呼び寸法です。肉厚のミル公差は通常 −12.5% で、'
          '耐圧計算では効いてきます。',
    ],
    references: [
      'ASME B36.10M, Welded and Seamless Wrought Steel Pipe',
      'ASME B31.3, Process Piping',
    ],
  ),
  505: ToolHelp(
    summary: '寸法の連なりに対する一次元の公差積上げを、最悪値法と統計法（RSS）の'
        '両方で行います。閉じるすきま、それが負になり得るか、'
        'そしてどの寸法がばらつきの大半を占めるか——'
        '公差を締めて最も効果が大きいのはその寸法です。',
    formulas: [
      HelpFormula(
        tex: r'g = \sum \pm d_i, \quad '
            r'T_{wc} = \sum t_i',
        plain: 'g = Σ ±di、Twc = Σ ti',
        caption: '最悪値法：公差は算術的に加算される',
      ),
      HelpFormula(
        tex: r'T_{rss} = \sqrt{\sum t_i^2}',
        plain: 'Trss = √(Σ ti²)',
        caption: 'RSS：公差は二乗和で加算される',
      ),
    ],
    symbols: [
      HelpSymbol('di', '連なりの各寸法の基準値', 'mm'),
      HelpSymbol('ti', '各寸法の対称換算した片側公差', 'mm'),
      HelpSymbol('g', '閉じるすきま', 'mm'),
    ],
    notes: [
      '最悪値法は単純な足し引きで、反論の余地がありません。'
          'これが成立すれば組立は必ず可能です。寸法決定はこちらで行ってください。',
      'RSS は各寸法が独立にばらつき、公差域の中央にあり、'
          'おおむね正規分布であることを前提とします。5 個程度の小さな数では'
          '意味をもたず、工程が偏るときや供給者が公差域の端で作るときは'
          'ばらつきを小さく見積もります。',
      'RSS の寄与率は各公差の二乗に比例するため、最悪値法の寄与率よりも'
          'はるかに強く、最も緩い寸法を指し示します。締めるべきはその寸法です。',
      '非対称公差は統計的な平均値をずらします。25 +0.10/−0.00 は実際には'
          '25.05 ±0.05 であり、25 として積み上げると連なり全体が低めに偏ります。',
      '一次元のみです。角度の影響、形状誤差、位置度公差には'
          '完全な三次元の公差解析が必要です。',
    ],
    references: [
      'ASME Y14.5, Dimensioning and Tolerancing',
      'Fischer, Mechanical Tolerance Stackup and Analysis',
    ],
  ),
};
