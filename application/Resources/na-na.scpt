FasdUAS 1.101.10   ��   ��    k             l     �� ��    P Jproperty wherefolder : "%%%LOGFOLDER%%%" -- last character must not be "/"       	  l     �� 
��   
 , &property rosettapath : "%%%ROSETTA%%%"    	     l     �� ��    0 *property downloadedhtmlPath : "%%%HTML%%%"         l     ������  ��        l     �� ��     on run         i         I      �� ���� 0 do_your_task        o      ���� 0 rosettapath        o      ���� 0 wherefolder     ��  o      ���� (0 downloadedhtmlpath downloadedhtmlPath��  ��    k     i       r        !   m      " "       ! o      ���� 0 myresult     # $ # l   ������  ��   $  % & % r     ' ( ' n    	 ) * ) 1    	��
�� 
strq * l    +�� + b     , - , o    ���� 0 wherefolder   - m     . .  /board.plist   ��   ( o      ���� 0 	argvposix 	argvPOSIX &  / 0 / r     1 2 1 l    3�� 3 I   �� 4��
�� .sysoexecTEXT���     TEXT 4 b     5 6 5 b     7 8 7 m     9 9  find     8 l    :�� : n     ; < ; 1    ��
�� 
strq < o    ���� 0 wherefolder  ��   6 m     = =   -name board.plist   ��  ��   2 o      ���� 0 ifplistexist   0  > ? > Z    & @ A���� @ l    B�� B =    C D C o    ���� 0 ifplistexist   D m     E E      ��   A l    " F G F L     " H H m     !��
�� 
null G   not need to sync   ��  ��   ?  I J I l  ' '������  ��   J  K L K r   ' , M N M n   ' * O P O 1   ( *��
�� 
strq P o   ' (���� 0 rosettapath   N o      ���� 0 plpath plPath L  Q R Q l  - -������  ��   R  S T S I  - <�� U��
�� .sysoexecTEXT���     TEXT U b   - 8 V W V b   - 2 X Y X b   - 0 Z [ Z m   - . \ \ 	 cp     [ o   . /���� 0 	argvposix 	argvPOSIX Y m   0 1 ] ]       W n   2 7 ^ _ ^ 1   5 7��
�� 
strq _ l  2 5 `�� ` b   2 5 a b a o   2 3���� 0 wherefolder   b m   3 4 c c  /board~.plist   ��  ��   T  d e d r   = L f g f b   = J h i h b   = H j k j b   = F l m l b   = B n o n b   = @ p q p m   = > r r  perl     q o   > ?���� 0 plpath plPath o m   @ A s s       m l  B E t�� t n   B E u v u 1   C E��
�� 
strq v o   B C���� (0 downloadedhtmlpath downloadedhtmlPath��   k m   F G w w       i o   H I���� 0 	argvposix 	argvPOSIX g o      ���� 0 myscript   e  x y x r   M T z { z I  M R�� |��
�� .sysoexecTEXT���     TEXT | o   M N���� 0 myscript  ��   { o      ���� 0 myresult   y  } ~ } Z   U b  �����  =  U X � � � o   U V���� 0 myresult   � m   V W � �       � r   [ ^ � � � m   [ \ � �  No URLs are modified.    � o      ���� 0 myresult  ��  ��   ~  � � � l  c c������  ��   �  ��� � L   c i � � c   c h � � � o   c d���� 0 myresult   � m   d g��
�� 
utxt��     ��� � l     ������  ��  ��       �� � ���   � ���� 0 do_your_task   � �� ���� � ����� 0 do_your_task  �� �� ���  �  �������� 0 rosettapath  �� 0 wherefolder  �� (0 downloadedhtmlpath downloadedhtmlPath��   � ������������������ 0 rosettapath  �� 0 wherefolder  �� (0 downloadedhtmlpath downloadedhtmlPath�� 0 myresult  �� 0 	argvposix 	argvPOSIX�� 0 ifplistexist  �� 0 plpath plPath�� 0 myscript   �  " .�� 9 =�� E�� \ ] c r s w � ���
�� 
strq
�� .sysoexecTEXT���     TEXT
�� 
null
�� 
utxt�� j�E�O��%�,E�O��,%�%j E�O��  �Y hO��,E�O�%�%��%�,%j O�%�%��,%�%�%E�O�j E�O��  �E�Y hO�a & ascr  ��ޭ