import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupAudioContext();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky, // ← Se oculta, pero reaparece con swipe
    overlays: [], // ← Sin botones visibles
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const DragDropApp());
  });
}

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

enum CharState { idle, active, playing }

class CharacterConfig {
  final String id;
  final String idleImg;
  final String activeImg;
  final String playingImg;
  final String audio; // Ruta relativa: 'sounds/filename.mp3'
  CharacterConfig({
    required this.id,
    required this.idleImg,
    required this.activeImg,
    required this.playingImg,
    required this.audio,
  });
}

class SelectorConfig {
  final String id;
  final String img;
  final String audio; // Ruta relativa: 'sounds/filename.mp3'
  SelectorConfig({required this.id, required this.img, required this.audio});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🎭 7 personajes
  final List<CharacterConfig> _characters = [
    CharacterConfig(id: 'p0', idleImg: 'assets/images/inicial_01.png', activeImg: 'assets/images/activo_01.png', playingImg: 'assets/images/reproduciendo_01.gif', audio: 'sounds/matimassa-drum-loop-trap.mp3'),
    CharacterConfig(id: 'p1', idleImg: 'assets/images/inicial_01.png', activeImg: 'assets/images/activo_02.png', playingImg: 'assets/images/reproduciendo_02.gif', audio: 'sounds/reverse-scratch.mp3'),
    CharacterConfig(id: 'p2', idleImg: 'assets/images/inicial_01.png', activeImg: 'assets/images/activo_03.png', playingImg: 'assets/images/reproduciendo_03.gif', audio: 'sounds/kick-sample.mp3'),
    CharacterConfig(id: 'p3', idleImg: 'assets/images/inicial_01.png', activeImg: 'assets/images/activo_04.png', playingImg: 'assets/images/reproduciendo_04.gif', audio: 'sounds/matimassa-drum-loop-trap.mp3'),
    CharacterConfig(id: 'p4', idleImg: 'assets/images/inicial_01.png', activeImg: 'assets/images/activo_05.png', playingImg: 'assets/images/reproduciendo_05.gif', audio: 'sounds/matimassa-drum-loop-trap.mp3'),
    CharacterConfig(id: 'p5', idleImg: 'assets/images/inicial_01.png', activeImg: 'assets/images/activo_06.png', playingImg: 'assets/images/reproduciendo_06.gif', audio: 'sounds/matimassa-drum-loop-trap.mp3'),
    CharacterConfig(id: 'p6', idleImg: 'assets/images/inicial_01.png', activeImg: 'assets/images/activo_07.png', playingImg: 'assets/images/reproduciendo_07.gif', audio: 'sounds/matimassa-drum-loop-trap.mp3'),
  ];

  // 🎛️ 14 selectores
  final List<SelectorConfig> _selectors = [
    SelectorConfig(id: 's0', img: 'assets/images/selector_01.png', audio: 'sounds/matimassa-drum-loop-trap.mp3'),
    SelectorConfig(id: 's1', img: 'assets/images/selector_02.png', audio: 'sounds/reverse-scratch.mp3'),
    SelectorConfig(id: 's2', img: 'assets/images/selector_03.png', audio: 'sounds/10.mp3'),
    SelectorConfig(id: 's3', img: 'assets/images/selector_04.png', audio: 'sounds/01.mp3'),
    SelectorConfig(id: 's4', img: 'assets/images/selector_05.png', audio: 'sounds/02.mp3'),
    SelectorConfig(id: 's5', img: 'assets/images/selector_06.png', audio: 'sounds/03.mp3'),
    SelectorConfig(id: 's6', img: 'assets/images/selector_07.png', audio: 'sounds/04.mp3'),
    SelectorConfig(id: 's7', img: 'assets/images/selector_07.png', audio: 'sounds/05.mp3'),
    SelectorConfig(id: 's8', img: 'assets/images/selector_06.png', audio: 'sounds/06.mp3'),
    SelectorConfig(id: 's9', img: 'assets/images/selector_05.png', audio: 'sounds/07.mp3'),
    SelectorConfig(id: 's10', img: 'assets/images/selector_04.png', audio: 'sounds/08.mp3'),
    SelectorConfig(id: 's11', img: 'assets/images/selector_03.png', audio: 'sounds/09.mp3'),
    SelectorConfig(id: 's12', img: 'assets/images/selector_02.png', audio: 'sounds/11.mp3'),
    SelectorConfig(id: 's13', img: 'assets/images/selector_01.png', audio: 'sounds/12.mp3'),
  ];

  final List<CharState> _charStates = List.filled(7, CharState.idle);
  
  // 🔊 Players con configuración working de tu mixer
  late final List<AudioPlayer> _players;
  
  final Map<int, int> _parkedSelectors = {};
  final Map<int, bool> _isMuted = {};

  @override
  void initState() {
    super.initState();
    _initPlayers(); // ← Inicializa players con configuración working
  }

  // 🔊 Inicializa cada player con la configuración que SÍ funciona
  Future<void> _initPlayers() async {
    _players = List.generate(7, (i) => AudioPlayer(playerId: 'char_$i'));
    
    for (var player in _players) {
      await _configurePlayer(player);
    }
  }

  // 🔊 Configuración exacta de tu mixer working
  Future<void> _configurePlayer(AudioPlayer player) async {
    await player.setPlayerMode(PlayerMode.mediaPlayer);
    
    await player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,  // ← Nombre correcto del enum
          audioFocus: AndroidAudioFocus.none, // ← CLAVE: permite audio simultáneo
        ),
      ),
    );
    
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(0.8);
  }

  @override
  void dispose() {
    for (var p in _players) p.dispose();
    super.dispose();
  }

  // 🔊 Activa personaje (usa ruta relativa como en tu mixer)
  Future<void> _activateCharacter(int charIndex, int selectorIndex) async {
    if (_charStates[charIndex] == CharState.playing) return;
    
    final selectorAudio = _selectors[selectorIndex].audio; // Ya es 'sounds/...'
    final player = _players[charIndex];
    
    try {
      await player.stop();
      await player.setVolume(0.8);
      await Future.delayed(const Duration(milliseconds: 20));
      
      // ✅ Usa AssetSource con ruta relativa (sin 'assets/')
      await player.play(AssetSource(selectorAudio));
      
      if (mounted) {
        setState(() {
          _parkedSelectors[charIndex] = selectorIndex;
          _charStates[charIndex] = CharState.playing;
          _isMuted[charIndex] = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  // 🔇 Mute con volumen (como en tu mixer)
  void _toggleMute(int charIndex) {
    if (!_parkedSelectors.containsKey(charIndex)) return;
    final player = _players[charIndex];
    final currentlyMuted = _isMuted[charIndex] ?? false;
    
    if (currentlyMuted) {
    // 🔊 DESMUTEAR: Reanuda el stream desde donde se pausó
    player.resume();
    player.setVolume(0.8); // Restaura volumen normal
  } else {
    // 🔇 MUTEAR: Detiene el stream a nivel de SO
    // ✅ Las grabadoras de pantalla YA NO capturarán audio
    player.pause();
    player.setVolume(0); // 🔒 Capa extra de seguridad (opcional)
  }
    
    setState(() => _isMuted[charIndex] = !currentlyMuted);
  }

// 🗑️ Remueve selector y resetea estado
  void _removeSelector(int charIndex) {
    if (!_parkedSelectors.containsKey(charIndex)) return;
    setState(() {
      _parkedSelectors.remove(charIndex);
      _charStates[charIndex] = CharState.idle;
      _isMuted.remove(charIndex);
    });
    _players[charIndex].stop();
    _players[charIndex].setVolume(0.8);
  }

  // 📋 Popup de información
void _showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      actionsPadding: const EdgeInsets.only(bottom: 12, right: 8, left: 8),
      
      // 🎯 Alineación de acciones a la izquierda
      actionsAlignment: MainAxisAlignment.start,
      
      // ✅ CORREGIDO: OverflowBarAlignment en lugar de OverflowAlignment
      actionsOverflowAlignment: OverflowBarAlignment.start,
      
      title: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.blueAccent),
          const SizedBox(width: 4),
          const Text('¿Cómo jugar?', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoItem('🎭 Personajes', 'Hay 7 personajes. Cada uno puede tener un sonido asignado.'),
            _infoItem('🎛️ Selectores', 'Arrastra un selector hacia un personaje para asignarle un sonido.'),
            _infoItem('▶️ Reproducción', 'El sonido comenzará automáticamente al asignarse.'),
            _infoItem('🔇 Silenciar', 'Toca el icono pequeño del selector en el personaje para muteear.'),
            _infoItem('❌ Remover', 'Arrastra el selector desde el personaje hacia afuera para quitarlo.'),
            
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
                      '💡 Tip: Puedes tener varios personajes reproduciendo sonidos al mismo tiempo para crear tu mezcla.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox.shrink(), 
          ],
        ),
      ),
      
      actions: [
  Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 🔘 BOTÓN ALINEADO A LA DERECHA
      Align(
        alignment: Alignment.centerRight, // ← 🎯 Botón a la derecha
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            
            child: const Text('¡Entendido!', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
        ),
      ),
      Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    color: Colors.grey[300],
  ),
      // 📝 CRÉDITOS ALINEADOS A LA IZQUIERDA
      Align(
        alignment: Alignment.centerLeft, // ← 🎯 Créditos a la izquierda
        child: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '👦 Una idea de Pipe Rodríguez. 👨‍💻 Desarrollado por whilrod@gmail.com', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color.fromARGB(255, 38, 22, 80)),
          ),
        ),
      ),
    ],
  ),
],
    ),
  );
}

// 📦 Widget auxiliar para items de información
Widget _infoItem(String title, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title  ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(description, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(padding: EdgeInsets.only(top: 0), child: Text('PIPEBOX', style: TextStyle(fontWeight: FontWeight.w400, fontFamily:"funky-glitzz" , fontSize: 48,color: Color.fromARGB(255, 45, 240, 143), fontStyle: FontStyle.italic))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 226, 226, 226),borderRadius: BorderRadius.circular(15),border: Border.all(color: Colors.grey[400]!, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2),blurRadius: 10,offset: const Offset(0, 4),),],
                ),
                child: Wrap(alignment: WrapAlignment.spaceEvenly,spacing: 16,runSpacing: 16,children: List.generate(7, (i) => _buildCharacter(i)),),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Text('🎛️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                  SizedBox(width: 8), // 👈 Opcional: añade un espacio pequeño entre el emoji y el texto
                  //Text('Samples', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28,fontFamily:"Super Squad Italic")),
                  Text('Samples', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,fontFamily:"Asteroid Blaster",color: Color.fromARGB(255, 38, 22, 80))),
                ],
              ),
              Column(

                children: [
                  Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 14, runSpacing: 14, children: List.generate(7, (i) => _buildSelector(i))),
                  SizedBox(height: 10),
                  Wrap(alignment: WrapAlignment.spaceEvenly, spacing: 14, runSpacing: 14, children: List.generate(7, (i) => _buildSelector(i + 7))),
                ],
              ),
                Row(
                  children:  [
                  const Text('Ver. 0.1.7  ', style: TextStyle(fontSize: 14,fontFamily:"Super Squad Italic",color: Color.fromARGB(255, 38, 22, 80))),

                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20, color: Colors.blueAccent),onPressed: () => _showInfoDialog(context),
                    tooltip: 'Cómo jugar',padding: EdgeInsets.zero,constraints: const BoxConstraints(),
                    ),
                  const Text('', style: TextStyle(fontSize: 14,fontFamily:"Super Squad Italic",color: Color.fromARGB(255, 38, 22, 80))),
                ],
                
              ),
             ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacter(int index) {
    final hasParked = _parkedSelectors.containsKey(index);
    final state = _charStates[index];
    final isMuted = _isMuted[index] ?? false;
    final config = _characters[index];

    return DragTarget<String>(
      onWillAccept: (data) => !hasParked,
      onAccept: (data) {
        final selectorIndex = _selectors.indexWhere((s) => s.id == data);
        if (selectorIndex >= 0) {
          _activateCharacter(index, selectorIndex);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty && !hasParked && state != CharState.playing;
        
        final String currentImg = switch (state) {
          CharState.playing => config.playingImg,
          CharState.active || _ => isHovering ? config.activeImg : config.idleImg,
        };
        
        return Container(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedScale(
                scale: state == CharState.playing ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26, width: 2),
                    boxShadow: state == CharState.playing
                        ? [BoxShadow(
                            color: isMuted ? Colors.red.withValues(alpha: 0.5) : const Color.fromARGB(255, 59, 250, 139).withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )]
                        : isHovering
                            ? [BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )]
                            : [BoxShadow(color: const Color.fromARGB(255, 252, 251, 251).withValues(alpha:0.9))],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      currentImg,
                      fit: BoxFit.cover,
                      key: ValueKey(currentImg),
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30, color: Colors.black54),
                    ),
                  ),
                ),
              ),
              
              if (hasParked)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _toggleMute(index),
                    child: Draggable<String>(
                      data: 'parked_${_parkedSelectors[index]}',
                      feedback: Transform.scale(
                        scale: 1.0,
                        child: _selectorVisual(_selectors[_parkedSelectors[index]!].img),
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      child: Transform.scale(
                        scale: 0.6,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _selectorVisual(_selectors[_parkedSelectors[index]!].img),
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
              
              if (hasParked && isMuted)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.volume_off, size: 8, color: Colors.white),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelector(int index) {
  final config = _selectors[index];
  
  // Si ya está asignado a un personaje, mostrar espacio vacío reservado
  if (_parkedSelectors.values.contains(index)) {
    return SizedBox(width: 52, height: 52); // ← Mismo tamaño que el selector
  }
  
  return Draggable<String>(
    data: config.id,
    // ✅ feedback: flota sobre la UI sin afectar el layout
    feedback: Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 1.1, // ← Efecto visual de "levantar"
        child: _selectorVisual(config.img),
      ),
    ),
    // ✅ childWhenDragging: MANTIENE EL ESPACIO con mismo tamaño
    childWhenDragging: SizedBox(
      width: 52,
      height: 52,
      child: Opacity(
        opacity: 0.3,
        child: _selectorVisual(config.img), // ← Visual fantasma opcional
      ),
    ),
    // ✅ child: widget normal visible
    child: _selectorVisual(config.img),
  );
}

  Widget _selectorVisual(String imagePath) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.4.clamp(0.0, 1.0)), blurRadius: 8),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.play_arrow, size: 24, color: Colors.blueAccent),
        ),
      ),
    );
  }
}