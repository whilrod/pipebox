import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';

// ============================================================================
// 🔊 CONFIGURACIÓN GLOBAL DE AUDIO
// ============================================================================
Future<void> setupAudioContext() async {
  await AudioPlayer.global.setAudioContext(
    AudioContext(
      android: AudioContextAndroid(
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    ),
  );
}

// ============================================================================
// 🚀 ENTRY POINT
// ============================================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupAudioContext();
  
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const DragDropApp());
  });
}

// ============================================================================
// 📱 APP ROOT
// ============================================================================
class DragDropApp extends StatelessWidget {
  const DragDropApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// ============================================================================
// 🎮 MODELOS Y ESTADOS
// ============================================================================
enum CharState { idle, active, playing }

class SelectorConfig {
  final String id;
  final String idleImg;      // Imagen neutra del selector
  final String activeImg;    // Imagen al pasar/hover
  final String playingImg;   // Animación/GIF al reproducir
  final String audio;        // Ruta del sonido
  SelectorConfig({
    required this.id,
    required this.idleImg,
    required this.activeImg,
    required this.playingImg,
    required this.audio,
  });
}

// ============================================================================
// 🏠 HOME SCREEN
// ============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 📦 Configuración de los 14 selectores (cada uno trae su personaje + animación + audio)
  // ⚠️ AJUSTA LAS RUTAS DE IMAGENES SEGÚN TUS ARCHIVOS REALES
  final List<SelectorConfig> _selectors = [
    SelectorConfig(id: 's0', idleImg: 'assets/images/selector_01.png', activeImg: 'assets/images/activo_01.png', playingImg: 'assets/images/reproduciendo_01.gif', audio: 'sounds/01.mp3'),
    SelectorConfig(id: 's1', idleImg: 'assets/images/selector_02.png', activeImg: 'assets/images/activo_02.png', playingImg: 'assets/images/reproduciendo_02.gif', audio: 'sounds/02.mp3'),
    SelectorConfig(id: 's2', idleImg: 'assets/images/selector_03.png', activeImg: 'assets/images/activo_03.png', playingImg: 'assets/images/reproduciendo_03.gif', audio: 'sounds/03.mp3'),
    SelectorConfig(id: 's3', idleImg: 'assets/images/selector_04.png', activeImg: 'assets/images/activo_04.png', playingImg: 'assets/images/reproduciendo_04.gif', audio: 'sounds/04.mp3'),
    SelectorConfig(id: 's4', idleImg: 'assets/images/selector_05.png', activeImg: 'assets/images/activo_05.png', playingImg: 'assets/images/reproduciendo_05.gif', audio: 'sounds/05.mp3'),
    SelectorConfig(id: 's5', idleImg: 'assets/images/selector_06.png', activeImg: 'assets/images/activo_06.png', playingImg: 'assets/images/reproduciendo_06.gif', audio: 'sounds/06.mp3'),
    SelectorConfig(id: 's6', idleImg: 'assets/images/selector_07.png', activeImg: 'assets/images/activo_07.png', playingImg: 'assets/images/reproduciendo_07.gif', audio: 'sounds/07.mp3'),
    SelectorConfig(id: 's7', idleImg: 'assets/images/selector_07.png', activeImg: 'assets/images/activo_07.png', playingImg: 'assets/images/reproduciendo_07.gif', audio: 'sounds/08.mp3'),
    SelectorConfig(id: 's8', idleImg: 'assets/images/selector_06.png', activeImg: 'assets/images/activo_06.png', playingImg: 'assets/images/reproduciendo_06.gif', audio: 'sounds/09.mp3'),
    SelectorConfig(id: 's9', idleImg: 'assets/images/selector_05.png', activeImg: 'assets/images/activo_05.png', playingImg: 'assets/images/reproduciendo_05.gif', audio: 'sounds/10.mp3'),
    SelectorConfig(id: 's10', idleImg: 'assets/images/selector_04.png', activeImg: 'assets/images/activo_04.png', playingImg: 'assets/images/reproduciendo_04.gif', audio: 'sounds/11.mp3'),
    SelectorConfig(id: 's11', idleImg: 'assets/images/selector_03.png', activeImg: 'assets/images/activo_03.png', playingImg: 'assets/images/reproduciendo_03.gif', audio: 'sounds/12.mp3'),
    SelectorConfig(id: 's12', idleImg: 'assets/images/selector_02.png', activeImg: 'assets/images/activo_02.png', playingImg: 'assets/images/reproduciendo_02.gif', audio: 'sounds/13.mp3'),
    SelectorConfig(id: 's13', idleImg: 'assets/images/selector_01.png', activeImg: 'assets/images/activo_01.png', playingImg: 'assets/images/reproduciendo_01.gif', audio: 'sounds/14.mp3'),
  ];

  final List<CharState> _charStates = List.filled(7, CharState.idle);
  final Map<int, int> _slotSelectors = {}; // slotIndex -> selectorIndex
  final Map<int, bool> _isMuted = {};
  late final List<AudioPlayer> _players;

  @override
  void initState() {
    super.initState();
    _initPlayers();
  }

  Future<void> _initPlayers() async {
    _players = List.generate(7, (i) => AudioPlayer(playerId: 'char_$i'));
    for (var player in _players) await _configurePlayer(player);
  }

  Future<void> _configurePlayer(AudioPlayer player) async {
    await player.setPlayerMode(PlayerMode.mediaPlayer);
    await player.setAudioContext(AudioContext(android: AudioContextAndroid(
      isSpeakerphoneOn: false, stayAwake: false, contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media, audioFocus: AndroidAudioFocus.none,
    )));
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(0.8);
  }

  @override
  void dispose() {
    for (var p in _players) p.dispose();
    super.dispose();
  }

  Future<void> _activateCharacter(int slotIndex, int selectorIndex) async {
    if (_charStates[slotIndex] == CharState.playing) return;
    final player = _players[slotIndex];
    final audioPath = _selectors[selectorIndex].audio;
    try {
      await player.stop();
      await player.setVolume(0.8);
      await player.play(AssetSource(audioPath));
      if (mounted) setState(() {
        _slotSelectors[slotIndex] = selectorIndex;
        _charStates[slotIndex] = CharState.playing;
        _isMuted[slotIndex] = false;
      });
    } catch (e) { debugPrint('❌ Error activando: $e'); }
  }

  void _toggleMute(int slotIndex) {
    if (!_slotSelectors.containsKey(slotIndex)) return;
    final player = _players[slotIndex];
    final isMuted = _isMuted[slotIndex] ?? false;
    if (isMuted) { player.resume(); player.setVolume(0.8); }
    else { player.pause(); player.setVolume(0); }
    setState(() => _isMuted[slotIndex] = !isMuted);
  }

  void _removeSelector(int slotIndex) {
    if (!_slotSelectors.containsKey(slotIndex)) return;
    _players[slotIndex].stop();
    setState(() {
      _slotSelectors.remove(slotIndex);
      _charStates[slotIndex] = CharState.idle;
      _isMuted.remove(slotIndex);
    });
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 8, left: 8),
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: Colors.blueAccent),
            SizedBox(width: 4),
            Text('¿Cómo jugar?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoItem('🎭 Slots Neutros', 'Los 7 espacios inician con el personaje base.'),
              _infoItem('🎛️ Selectores', 'Arrastra un selector a un espacio. Este adoptará su personaje, animación y audio.'),
              _infoItem('▶️ Reproducción', 'El audio y la animación inician automáticamente al soltar.'),
              _infoItem('🔇 Silenciar', 'Toca el selector en el espacio para muteear.'),
              _infoItem('❌ Remover', 'Arrastra el selector fuera del espacio para restaurar el neutro.'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡 Combina varios slots para crear mezclas en tiempo real.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ✅ FIX: Acciones simplificadas sin OverflowBarAlignment
        actions: [
          // Botón principal alineado a la derecha
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                '¡Entendido!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
          ),
          // Línea divisoria
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[300],
          ),
          // Créditos alineados a la izquierda (con const corregido)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4), // ✅ FIX: const agregado
              child: const Text(
                '👦 Una idea de Pipe Rodríguez. 👨‍💻 Desarrollado por whilrod@gmail.com',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color.fromARGB(255, 38, 22, 80)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String description) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$title  ', style: const TextStyle(fontWeight: FontWeight.w600)), Expanded(child: Text(description, style: const TextStyle(fontSize: 13)))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        // ✅ DEBUG OVERLAY envuelve el área interactiva
        child: TouchDebugOverlay(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Padding(padding: EdgeInsets.only(top: 0), child: Text('PIPEBOX', style: TextStyle(fontWeight: FontWeight.w400, fontFamily:"funky-glitzz" , fontSize: 48,color: Color.fromARGB(255, 45, 240, 143), fontStyle: FontStyle.italic))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color.fromARGB(255, 226, 226, 226),borderRadius: BorderRadius.circular(15),border: Border.all(color: Colors.grey[400]!, width: 2),boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2),blurRadius: 10,offset: const Offset(0, 4),),],),
                child: Wrap(alignment: WrapAlignment.spaceEvenly,spacing: 16,runSpacing: 16,children: List.generate(7, (i) => _buildCharacter(i))),
              ),
              const SizedBox(height: 10),
              Row(children: const [Text('🎛️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)), SizedBox(width: 8), Text('Samples', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,fontFamily:"Asteroid Blaster",color: Color.fromARGB(255, 38, 22, 80))),]),
              Column(children: [
                Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 14, runSpacing: 14, children: List.generate(7, (i) => _buildSelector(i))),
                const SizedBox(height: 10),
                Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 14, runSpacing: 14, children: List.generate(7, (i) => _buildSelector(i + 7))),
              ]),
              Row(children:  [
                const Text('Ver. 0.1.9  ', style: TextStyle(fontSize: 14,fontFamily:"Super Squad Italic",color: Color.fromARGB(255, 38, 22, 80))),
                IconButton(icon: const Icon(Icons.info_outline, size: 20, color: Colors.blueAccent),onPressed: () => _showInfoDialog(context),tooltip: 'Cómo jugar',padding: EdgeInsets.zero,constraints: const BoxConstraints(),),
                const Text('', style: TextStyle(fontSize: 14,fontFamily:"Super Squad Italic",color: Color.fromARGB(255, 38, 22, 80))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

      Widget _buildCharacter(int index) {
    final bool hasSelector = _slotSelectors.containsKey(index);
    final CharState state = _charStates[index];
    final bool isMuted = _isMuted[index] ?? false;

    return DragTarget<String>(
      onWillAccept: (data) {
        debugPrint('[DROP] onWillAccept: slot=$index, data=$data, hasSelector=$hasSelector');
        return !hasSelector;
      },
      onAccept: (data) {
        debugPrint('[DROP] onAccept: slot=$index, selectorId=$data');
        final selectorIndex = _selectors.indexWhere((s) => s.id == data);
        if (selectorIndex >= 0) _activateCharacter(index, selectorIndex);
      },
      // ✅ FIX: onLeave para limpiar estado hover si el usuario sale del slot
      onLeave: (data) {
        debugPrint('[DROP] onLeave: slot=$index');
      },
      builder: (context, candidateData, rejectedData) {
        final bool isHovering = candidateData.isNotEmpty && !hasSelector && state != CharState.playing;
        
        // 🎯 Determinar imagen actual (lógica explícita)
        String currentImg = 'assets/images/inicial_01.png';
        double currentScale = 1.0;
        Color borderColor = Colors.black26;
        double borderGlow = 0;
        
        if (hasSelector) {
          // ✅ Slot ya ocupado: mostrar assets del selector asignado
          final selectorIndex = _slotSelectors[index]!;
          final config = _selectors[selectorIndex];
          
          if (state == CharState.playing) {
            currentImg = config.playingImg;
            currentScale = 1.05;
          } else {
            currentImg = config.idleImg;
            currentScale = 1.0;
          }
        } else if (isHovering) {
          // ✅ HOVER ACTIVO: Mostrar activo_xx.png + efecto visual
          final selectorId = candidateData.first;
          final selectorIndex = _selectors.indexWhere((s) => s.id == selectorId);
          
          if (selectorIndex >= 0) {
            final config = _selectors[selectorIndex];
            currentImg = config.activeImg; // ← 🎯 CAMBIO CLAVE: activo_xx.png
            currentScale = 1.15;           // ← 🎯 Escala para destacar
            borderColor = Colors.blueAccent;
            borderGlow = 4;                // ← 🎯 Glow azul
          }
        }

        // 🎨 Sombras con withValues() (Flutter 3.27+)
        Color shadowColor = Colors.white.withValues(alpha: 0.9);
        double shadowBlur = 10;
        double shadowSpread = 0;
        
        if (state == CharState.playing) {
          shadowColor = isMuted 
              ? Colors.red.withValues(alpha: 0.5) 
              : const Color.fromARGB(255, 59, 250, 139).withValues(alpha: 0.5);
          shadowBlur = 12;
          shadowSpread = 2;
        } else if (isHovering) {
          shadowColor = Colors.blueAccent.withValues(alpha: 0.7);
          shadowBlur = 16;  // ← Glow más intenso en hover
          shadowSpread = 4;
        }

        return MouseRegion(
          // ✅ Cursor pointer en web cuando es un drop válido
          cursor: isHovering ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedScale(
            scale: currentScale,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🎨 Borde dinámico + glow
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: isHovering ? 3 : 2, // ← Borde más grueso en hover
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: shadowBlur,
                          spreadRadius: shadowSpread,
                        ),
                      ],
                    ),
                  ),
                  // 🖼️ Imagen del personaje/selector
                  ClipOval(
                    child: Image.asset(
                      currentImg,
                      fit: BoxFit.cover,
                      key: ValueKey(currentImg), // ← Forza rebuild al cambiar imagen
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30, color: Colors.black54),
                      // ✅ Smooth loading para GIFs
                      gaplessPlayback: true,
                    ),
                  ),
                  
                  // ✅ Selector asignado: miniatura para remover/mutear
                  if (hasSelector)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _toggleMute(index),
                        child: Draggable<String>(
                          data: 'parked_${_slotSelectors[index]}',
                          feedback: Transform.scale(
                            scale: 1.0,
                            child: _selectorVisual(_selectors[_slotSelectors[index]!].idleImg),
                          ),
                          childWhenDragging: const SizedBox.shrink(),
                          child: Transform.scale(
                            scale: 0.6,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _selectorVisual(_selectors[_slotSelectors[index]!].idleImg),
                                if (isMuted)
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.volume_off, size: 8, color: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                          onDragStarted: () => _removeSelector(index),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelector(int index) {
    final config = _selectors[index];
    // Si ya está asignado a un slot, dejar espacio vacío
    if (_slotSelectors.values.contains(index)) return SizedBox(width: 52, height: 52);
    
    return Draggable<String>(
      data: config.id,
      onDragStarted: () => debugPrint('[DRAG] START: selector=${config.id}'),
      onDragCompleted: () => debugPrint('[DRAG] COMPLETED: selector=${config.id}'),
      onDraggableCanceled: (velocity, offset) => debugPrint('[DRAG] CANCELED: selector=${config.id}'),
      feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.1, child: _selectorVisual(config.idleImg))),
      childWhenDragging: SizedBox(width: 52, height: 52, child: Opacity(opacity: 0.3, child: _selectorVisual(config.idleImg))),
      child: _selectorVisual(config.idleImg),
    );
  }

  Widget _selectorVisual(String imagePath) => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 2), boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.4.clamp(0.0, 1.0)), blurRadius: 8)]),
    child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.play_arrow, size: 24, color: Colors.blueAccent))),
  );
}

// ============================================================================
// 🔍 TOUCH DEBUG OVERLAY (Para depuración en web móvil)
// ============================================================================
class TouchDebugOverlay extends StatefulWidget {
  final Widget child;
  const TouchDebugOverlay({required this.child, super.key});
  @override
  State<TouchDebugOverlay> createState() => _TouchDebugOverlayState();
}

class _TouchDebugOverlayState extends State<TouchDebugOverlay> {
  final Map<int, Offset> _touches = {};
  void _log(PointerEvent e, String type) {
    if (e.kind == PointerDeviceKind.touch) {
      setState(() => type == 'UP' ? _touches.remove(e.pointer) : _touches[e.pointer] = e.position);
      final pos = '(${e.position.dx.toStringAsFixed(1)}, ${e.position.dy.toStringAsFixed(1)})';
      debugPrint('[TOUCH $type] ID:${e.pointer} GLOBAL:$pos');
    }
  }
  @override
  Widget build(BuildContext context) => Stack(children: [
    widget.child,
    Positioned.fill(child: Listener(behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _log(e, 'DOWN'), onPointerMove: (e) => _log(e, 'MOVE'), onPointerUp: (e) => _log(e, 'UP'),
      child: IgnorePointer(child: CustomPaint(painter: _TouchPainter(_touches))),
    )),
  ]);
}

class _TouchPainter extends CustomPainter {
  final Map<int, Offset> touches;
  _TouchPainter(this.touches);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.yellowAccent.withOpacity(0.6)..style = PaintingStyle.fill;
    for (final offset in touches.values) {
      canvas.drawCircle(offset, 18, paint);
      canvas.drawCircle(offset, 18, Paint()..color = Colors.white..style = PaintingStyle.stroke);
    }
  }
  @override
  bool shouldRepaint(covariant _TouchPainter oldDelegate) => true;
}