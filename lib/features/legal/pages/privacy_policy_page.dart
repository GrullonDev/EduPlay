import 'package:flutter/material.dart';

import 'package:edu_play/features/legal/pages/legal_shared.dart';

const _kLastUpdated = '24 de junio de 2026';

const _sections = <LegalSection>[
  LegalSection(
    title: '1. Información que recopilamos',
    body:
        'EduPlay recopila únicamente la información necesaria para brindar una '
        'experiencia educativa segura y personalizada.\n\n'
        '• Datos de cuenta: nombre, correo electrónico y contraseña cifrada del padre, '
        'madre o tutor.\n'
        '• Perfil del niño: nombre o apodo, edad y avatar seleccionado. No '
        'recopilamos documentos de identidad ni información sensible de menores.\n'
        '• Datos de uso: juegos jugados, tiempo de sesión, puntuaciones y logros, '
        'utilizados para personalizar el aprendizaje.\n'
        '• Información técnica: tipo de dispositivo, sistema operativo y versión de '
        'la aplicación, con fines de diagnóstico.',
  ),
  LegalSection(
    title: '2. Cómo usamos la información',
    body:
        'Usamos los datos recopilados para:\n\n'
        '• Proporcionar y mejorar las funcionalidades de la plataforma.\n'
        '• Generar reportes de progreso para padres y maestros.\n'
        '• Personalizar el nivel de dificultad y el contenido educativo.\n'
        '• Enviar comunicaciones relacionadas con la cuenta (no publicidad).\n'
        '• Cumplir con obligaciones legales aplicables.\n\n'
        'Nunca vendemos ni compartimos los datos personales de los niños con '
        'terceros para fines comerciales.',
  ),
  LegalSection(
    title: '3. Protección de datos de menores',
    body:
        'EduPlay está diseñada pensando en niños de 3 a 12 años y cumple con '
        'los principios de la Convención de los Derechos del Niño de la ONU y '
        'las mejores prácticas internacionales para aplicaciones educativas.\n\n'
        '• Los perfiles de niños solo pueden ser creados por un adulto con cuenta '
        'verificada.\n'
        '• Los niños no pueden comunicarse con extraños ni compartir información '
        'personal dentro de la plataforma.\n'
        '• Las sesiones de juego de invitado no almacenan datos personales '
        'identificables de forma permanente.',
  ),
  LegalSection(
    title: '4. Almacenamiento y seguridad',
    body:
        'Los datos se almacenan en servidores seguros proporcionados por Google '
        'Firebase (con certificación SOC 2 e ISO 27001). Aplicamos:\n\n'
        '• Cifrado en tránsito mediante TLS 1.3.\n'
        '• Cifrado en reposo para contraseñas y datos sensibles.\n'
        '• Autenticación multifactor disponible para cuentas de padres.\n'
        '• Revisiones periódicas de seguridad y acceso restringido al equipo '
        'técnico.',
  ),
  LegalSection(
    title: '5. Cookies y tecnologías similares',
    body:
        'La versión web de EduPlay utiliza cookies de sesión estrictamente '
        'necesarias para mantener el inicio de sesión. No usamos cookies de '
        'rastreo ni publicidad comportamental. Puedes desactivar las cookies en '
        'tu navegador, aunque esto puede afectar el funcionamiento de la '
        'plataforma.',
  ),
  LegalSection(
    title: '6. Tus derechos',
    body:
        'Como padre, madre o tutor tienes derecho a:\n\n'
        '• Acceder a los datos de tu cuenta y los perfiles de tus hijos.\n'
        '• Corregir información inexacta.\n'
        '• Solicitar la eliminación completa de la cuenta y todos los datos '
        'asociados.\n'
        '• Exportar los datos de progreso en formato PDF.\n\n'
        'Para ejercer estos derechos, escríbenos a privacidad@eduplay.app o '
        'desde la sección Configuración → Privacidad dentro de la app.',
  ),
  LegalSection(
    title: '7. Retención de datos',
    body:
        'Conservamos los datos de la cuenta mientras esta permanezca activa. '
        'Al eliminar la cuenta, borramos toda la información personal en un '
        'plazo máximo de 30 días, salvo que la ley exija conservarla por un '
        'período mayor.',
  ),
  LegalSection(
    title: '8. Cambios a esta política',
    body:
        'Podemos actualizar esta Política de Privacidad periódicamente. Te '
        'notificaremos por correo electrónico y mediante un aviso en la '
        'aplicación con al menos 15 días de antelación ante cambios '
        'significativos. El uso continuado de EduPlay tras la fecha de vigencia '
        'implica la aceptación de los cambios.',
  ),
  LegalSection(
    title: '9. Contacto',
    body:
        'Si tienes preguntas sobre esta política o sobre el tratamiento de tus '
        'datos, puedes contactarnos en:\n\n'
        'EduPlay Learning — GrullonDev\n'
        'Correo: privacidad@eduplay.app\n'
        'Sitio web: www.eduplay.app',
  ),
];

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScaffold(
      title: 'Política de Privacidad',
      icon: Icons.shield_rounded,
      iconColor: Color(0xFF43A047),
      sections: _sections,
      lastUpdated: _kLastUpdated,
      intro:
          'En EduPlay nos tomamos muy en serio la privacidad de los niños y sus '
          'familias. Esta política explica qué datos recopilamos, cómo los '
          'usamos y cómo los protegemos.',
    );
  }
}
