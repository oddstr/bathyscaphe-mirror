FasdUAS 1.101.10   ��   ��    k             l     �� ��    $ property plPath : "%%%SORA%%%"       	  l     �� 
��   
 0 *property downloadedhtmlPath : "%%%HTML%%%"    	     l     �� ��    ' !property ftoolPath : "%%%SJIS%%%"         l     �� ��    P Jproperty wherefolder : "%%%LOGFOLDER%%%" -- last character must not be "/"         l     ������  ��        l     �� ��     on run         i         I      �� ���� 0 do_your_task        o      ���� 0 plpath plPath      o      ���� 0 	ftoolpath 	ftoolPath       o      ���� 0 wherefolder      !�� ! o      ���� (0 downloadedhtmlpath downloadedhtmlPath��  ��    k     V " "  # $ # r      % & % m      ' '       & o      ���� 0 myresult   $  ( ) ( l   ������  ��   )  * + * r     , - , n    	 . / . 1    	��
�� 
strq / l    0�� 0 b     1 2 1 o    ���� 0 wherefolder   2 m     3 3  /board_default.plist   ��   - o      ���� 0 defaultplist defaultPlist +  4 5 4 r     6 7 6 l    8�� 8 I   �� 9��
�� .sysoexecTEXT���     TEXT 9 b     : ; : b     < = < m     > >  find     = l    ?�� ? n     @ A @ 1    ��
�� 
strq A o    ���� 0 wherefolder  ��   ; m     B B    -name board_default.plist   ��  ��   7 o      ���� 0 ifplistexist   5  C D C Z    3 E F���� E l    G�� G >    H I H o    ���� 0 ifplistexist   I m     J J      ��   F l    / K L K I    /�� M��
�� .sysoexecTEXT���     TEXT M b     + N O N b     % P Q P b     # R S R m     ! T T 	 cp     S o   ! "���� 0 defaultplist defaultPlist Q m   # $ U U       O n   % * V W V 1   ( *��
�� 
strq W l  % ( X�� X b   % ( Y Z Y o   % &���� 0 wherefolder   Z m   & ' [ [  /board_default~.plist   ��  ��   L    file exists, so backup it   ��  ��   D  \ ] \ l  4 4������  ��   ]  ^ _ ^ r   4 K ` a ` b   4 I b c b b   4 G d e d b   4 E f g f b   4 A h i h b   4 ? j k j b   4 ; l m l b   4 9 n o n m   4 5 p p  perl     o l  5 8 q�� q n   5 8 r s r 1   6 8��
�� 
strq s o   5 6���� 0 plpath plPath��   m m   9 : t t       k l  ; > u�� u n   ; > v w v 1   < >��
�� 
strq w o   ; <���� (0 downloadedhtmlpath downloadedhtmlPath��   i m   ? @ x x       g l  A D y�� y n   A D z { z 1   B D��
�� 
strq { o   A B���� 0 	ftoolpath 	ftoolPath��   e m   E F | | 	  >     c o   G H���� 0 defaultplist defaultPlist a o      ���� 0 myscript   _  } ~ } r   L S  �  I  L Q�� ���
�� .sysoexecTEXT���     TEXT � o   L M���� 0 myscript  ��   � o      ���� 0 myresult   ~  ��� � L   T V � � o   T U���� 0 myresult  ��     ��� � l     ������  ��  ��       �� � ���   � ���� 0 do_your_task   � �� ���� � ����� 0 do_your_task  �� �� ���  �  ���������� 0 plpath plPath�� 0 	ftoolpath 	ftoolPath�� 0 wherefolder  �� (0 downloadedhtmlpath downloadedhtmlPath��   � ������������������ 0 plpath plPath�� 0 	ftoolpath 	ftoolPath�� 0 wherefolder  �� (0 downloadedhtmlpath downloadedhtmlPath�� 0 myresult  �� 0 defaultplist defaultPlist�� 0 ifplistexist  �� 0 myscript   �  ' 3�� > B�� J T U [ p t x |
�� 
strq
�� .sysoexecTEXT���     TEXT�� W�E�O��%�,E�O��,%�%j E�O�� �%�%��%�,%j Y hO��,%�%��,%�%��,%�%�%E�O�j E�O�ascr  ��ޭ