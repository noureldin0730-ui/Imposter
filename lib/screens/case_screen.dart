class _CaseScreenState extends State<CaseScreen>
    with SingleTickerProviderStateMixin {
  late Case _case;
  late TabController _tabs;
  int _wrongAttempts = 0;

  @override
  void initState() {
    super.initState();
    _case = getCase(widget.caseId);
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ═══════════════ حساب النجوم ═══════════════
  int _calculateStars() {
    if (_wrongAttempts == 0) return 3;
    if (_wrongAttempts == 1) return 2;
    return 1;
  }

  Future<void> _onAccuse(String suspectName) async {
    final isCorrect = suspectName == _case.killer;
    if (isCorrect) {
      HapticFeedback.lightImpact();

      // ═══ احفظ النجوم الحقيقية ═══
      final stars = _calculateStars();
      await SaveManager.setStars(_case.id, stars);

      if (_case.id < kTotalCases) {
        await SaveManager.unlock(_case.id + 1);
        await SaveManager.setCurrentCase(_case.id + 1);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AccuseScreen(
            caseData: _case,
            accused: suspectName,
            correct: true,
            stars: stars,
          ),
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      // ═══ خصم محاولة ═══
      setState(() => _wrongAttempts++);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AccuseScreen(
            caseData: _case,
            accused: suspectName,
            correct: false,
            stars: 0,
          ),
        ),
      );
    }
  }

  void _openAccuseMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: P.dark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AccuseSheet(
        suspects: _case.suspects,
        onPick: (name) {
          Navigator.of(context).pop();
          _onAccuse(name);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: P.dim,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'القضية ${_case.id} من $kTotalCases',
                          style: const TextStyle(
                            color: P.rare,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _case.title,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: P.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ═══ عرض المحاولات ═══
                  if (_wrongAttempts > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: P.rare),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: P.rare,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'محاولات غلط: $_wrongAttempts',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: P.rare,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1A1A1A), height: 1),
            Container(
              color: P.dark,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                labelColor: P.rare,
                unselectedLabelColor: P.dim,
                indicatorColor: P.rare,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'الجريمة'),
                  Tab(text: 'الضحية'),
                  Tab(text: 'المشتبه بهم'),
                  Tab(text: 'الأدلة'),
                  Tab(text: 'شهادات'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _CrimeTab(c: _case),
                  _VictimTab(c: _case),
                  _SuspectsTab(c: _case),
                  _EvidenceTab(c: _case),
                  _TestimonyTab(c: _case),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0A0807),
                border: Border(
                  top: BorderSide(color: Color(0xFF1A1A1A)),
                ),
              ),
              child: GestureDetector(
                onTap: _openAccuseMenu,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: P.mid,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: P.rare.withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Text(
                    'اتهم المشتبه به',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: P.white,
                      fontSize: 16,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}