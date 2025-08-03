import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/tts_service.dart';

Widget speakButton(String line){
  return IconButton(
    icon: const Icon(Icons.volume_up, size: 18),
    onPressed: () async{
      await TTSService().speak(line);
    },
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),
  );
}