// lib/hub/hubone/policy.dart
import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Политика конфиденциальности',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SoW — Suppression of Weakness',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'Настоящая Политика конфиденциальности (далее — «Политика») описывает, как ваше приложение SoW — Suppression of Weakness (далее — «Приложение») собирает, использует и защищает личную информацию пользователей.',
                ),
                const SizedBox(height: 20),
                _buildHeader('1. Собираемая информация'),
                _buildSection(
                  '1.1. При регистрации и использовании Приложения пользователи могут предоставить следующую информацию:\n\n• имя пользователя;\n• адрес электронной почты;\n• пароль;\n• данные о физической активности (например, виды тренировок, интенсивность, частота);\n• личные цели и предпочтения в тренировках;\n• другая информация, необходимая для функционирования Приложения.',
                ),
                _buildSection(
                  '1.2. Приложение может автоматически собирать определённые данные, такие как:\n\n• IP-адрес;\n• информация о вашем устройстве (например, модель устройства, версия операционной системы);\n• данные о взаимодействии с Приложением (например, время использования, частота посещений).',
                ),
                const SizedBox(height: 10),
                _buildHeader('2. Использование информации'),
                _buildSection(
                  '2.1. Предоставленная пользователями информация используется для следующих целей:\n\n• регистрация и аутентификация пользователей;\n• персонализация тренировок и рекомендаций;\n• улучшение функционала и удобства использования Приложения;\n• анализ эффективности тренировок и предоставление обратной связи;\n• взаимодействие с пользователями через уведомления и персонализированные сообщения.',
                ),
                _buildSection(
                  '2.2. Собираемая информация может быть использована для улучшения работы Приложения и оптимизации его функционала, но не будет передана третьим лицам без согласия пользователя, за исключением случаев, предусмотренных законодательством.',
                ),
                const SizedBox(height: 10),
                _buildHeader('3. Защита информации'),
                _buildSection(
                  '3.1. Приложение принимает необходимые технические и организационные меры для защиты личной информации пользователей от несанкционированного доступа, использования, раскрытия, изменения, уничтожения или потери.',
                ),
                _buildSection(
                  '3.2. Для защиты информации применяются современные технологии шифрования и безопасности данных.',
                ),
                const SizedBox(height: 10),
                _buildHeader('4. Передача информации третьим лицам'),
                _buildSection(
                  '4.1. Информация пользователей может быть передана третьим лицам только в следующих случаях:\n\n• по запросу государственных органов в рамках законодательства;\n• для обеспечения безопасности и функционирования Приложения;\n• в случае реорганизации или продажи бизнеса, связанного с Приложением.',
                ),
                _buildSection(
                  '4.2. В любом случае передача информации третьим лицам осуществляется с соблюдением всех применимых законов и норм.',
                ),
                const SizedBox(height: 10),
                _buildHeader('5. Права пользователей'),
                _buildSection(
                  '5.1. Пользователи имеют право на доступ к своей личной информации, её исправление и удаление.',
                ),
                _buildSection(
                  '5.2. Пользователи могут в любой момент изменить настройки конфиденциальности или отказаться от использования Приложения.',
                ),
                const SizedBox(height: 10),
                _buildHeader('6. Изменения в Политике'),
                _buildSection(
                  '6.1. Приложение оставляет за собой право вносить изменения в настоящую Политику в любое время.',
                ),
                _buildSection(
                  '6.2. О любых изменениях в Политике пользователи будут уведомлены через Приложение.',
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'Дата последнего обновления Политики: Вчера.\n\nНастоящая Политика конфиденциальности вступает в силу с момента её опубликования на сайте и в Приложении.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSection(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[300],
          height: 1.5,
        ),
      ),
    );
  }
}