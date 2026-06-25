import 'package:flutter/material.dart';

import 'package:edu_play/features/legal/pages/legal_shared.dart';

const _kLastUpdated = '24 de junio de 2026';

const _sections = <LegalSection>[
  LegalSection(
    title: '1. Aceptación de los términos',
    body:
        'Al crear una cuenta, acceder a EduPlay como invitado o utilizar '
        'cualquier función de la plataforma, aceptas estos Términos de '
        'Servicio. Si no estás de acuerdo con alguna parte, te pedimos que no '
        'uses el servicio.\n\n'
        'Los padres, madres o tutores legales son responsables de aceptar estos '
        'términos en nombre de los niños menores de edad que usen la plataforma.',
  ),
  LegalSection(
    title: '2. Descripción del servicio',
    body:
        'EduPlay es una plataforma de aprendizaje gamificado dirigida a niños de '
        '3 a 12 años. Ofrecemos:\n\n'
        '• Juegos educativos en áreas de matemáticas, ciencias, lenguaje, '
        'historia, arte y más.\n'
        '• Perfiles de progreso para padres y maestros.\n'
        '• Retos y misiones asignables por docentes.\n'
        '• Álbum de estampas y sistema de puntos (XP) como motivación.\n\n'
        'El servicio puede incluir funciones gratuitas y de pago (suscripción '
        'premium). Las funciones disponibles pueden variar según el plan.',
  ),
  LegalSection(
    title: '3. Cuentas de usuario',
    body:
        'Para acceder a todas las funciones debes crear una cuenta de padre/tutor '
        'o de maestro con un correo electrónico válido y una contraseña segura.\n\n'
        '• Eres responsable de mantener la confidencialidad de tus credenciales.\n'
        '• Debes notificarnos de inmediato si sospechas que tu cuenta ha sido '
        'comprometida.\n'
        '• No está permitido crear cuentas en nombre de terceros sin su '
        'consentimiento.\n'
        '• EduPlay se reserva el derecho de suspender cuentas que violen estos '
        'términos.',
  ),
  LegalSection(
    title: '4. Uso aceptable',
    body:
        'Te comprometes a no:\n\n'
        '• Usar la plataforma para actividades ilegales o que dañen a otros '
        'usuarios.\n'
        '• Intentar acceder a datos de otros usuarios sin autorización.\n'
        '• Reproducir, distribuir o modificar el contenido de EduPlay sin '
        'permiso expreso.\n'
        '• Usar herramientas automatizadas (bots, scrapers) para extraer '
        'contenido.\n'
        '• Publicar contenido inapropiado, ofensivo o que no sea apto para '
        'menores.',
  ),
  LegalSection(
    title: '5. Propiedad intelectual',
    body:
        'Todo el contenido de EduPlay — incluyendo diseños, ilustraciones, '
        'música, textos, código fuente y marcas — es propiedad de EduPlay '
        'Learning / GrullonDev o de sus licenciantes, y está protegido por las '
        'leyes de propiedad intelectual aplicables.\n\n'
        'Te concedemos una licencia limitada, no exclusiva y no transferible '
        'para usar el servicio con fines educativos personales. Esta licencia '
        'no incluye el derecho a sublicenciar, vender o explotar '
        'comercialmente el contenido.',
  ),
  LegalSection(
    title: '6. Suscripción y pagos',
    body:
        'EduPlay ofrece un plan gratuito con funciones básicas y un plan premium '
        'con acceso completo.\n\n'
        '• Los pagos se procesan de forma segura a través de proveedores '
        'certificados (Stripe u equivalente).\n'
        '• Las suscripciones se renuevan automáticamente salvo que las canceles '
        'antes de la fecha de renovación.\n'
        '• Puedes cancelar en cualquier momento desde Configuración → '
        'Suscripción. El acceso premium se mantiene hasta el final del período '
        'pagado.\n'
        '• No realizamos reembolsos por períodos parciales, salvo que la '
        'legislación aplicable lo exija.',
  ),
  LegalSection(
    title: '7. Disponibilidad del servicio',
    body:
        'Nos esforzamos por mantener EduPlay disponible 24/7, pero no '
        'garantizamos una disponibilidad ininterrumpida. Podemos realizar '
        'mantenimientos programados (con aviso previo) o experimentar '
        'interrupciones imprevistas.\n\n'
        'No somos responsables de daños o pérdidas derivados de la '
        'indisponibilidad temporal del servicio.',
  ),
  LegalSection(
    title: '8. Limitación de responsabilidad',
    body:
        'EduPlay se proporciona "tal cual". En la medida que lo permita la ley '
        'aplicable:\n\n'
        '• No garantizamos que el servicio esté libre de errores o que cumpla '
        'todos tus requisitos específicos.\n'
        '• No somos responsables de daños indirectos, incidentales o '
        'consecuentes derivados del uso o la imposibilidad de uso del servicio.\n'
        '• Nuestra responsabilidad total no excederá el monto pagado por el '
        'usuario en los 12 meses anteriores al evento que originó el reclamo.',
  ),
  LegalSection(
    title: '9. Modificaciones del servicio',
    body:
        'Podemos modificar, suspender o discontinuar funciones del servicio en '
        'cualquier momento. En caso de cambios significativos, te notificaremos '
        'con al menos 30 días de antelación por correo electrónico o mediante '
        'un aviso en la aplicación.\n\n'
        'También podemos actualizar estos Términos. Los cambios entran en vigor '
        'en la fecha indicada en el aviso. El uso continuado del servicio '
        'implica la aceptación de los términos actualizados.',
  ),
  LegalSection(
    title: '10. Ley aplicable y resolución de disputas',
    body:
        'Estos Términos se rigen por las leyes de la República Dominicana. '
        'Cualquier disputa se resolverá preferentemente mediante negociación '
        'directa. Si no se alcanza un acuerdo, las partes se someten a la '
        'jurisdicción de los tribunales competentes de Santo Domingo.\n\n'
        'Para usuarios de la Unión Europea: nada en estos Términos limita los '
        'derechos que te corresponden como consumidor bajo la legislación '
        'europea aplicable.',
  ),
  LegalSection(
    title: '11. Contacto',
    body:
        'Para preguntas sobre estos Términos de Servicio, escríbenos a:\n\n'
        'EduPlay Learning — GrullonDev\n'
        'Correo: legal@eduplay.app\n'
        'Sitio web: www.eduplay.app',
  ),
];

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScaffold(
      title: 'Términos de Servicio',
      icon: Icons.gavel_rounded,
      iconColor: Color(0xFF1E88E5),
      sections: _sections,
      lastUpdated: _kLastUpdated,
      intro:
          'Estos Términos de Servicio regulan el acceso y uso de EduPlay, la '
          'plataforma de aprendizaje gamificado de GrullonDev. Por favor, '
          'léelos con atención antes de registrarte o usar el servicio.',
    );
  }
}
