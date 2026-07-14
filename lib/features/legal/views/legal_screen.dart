import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/legal/view_models/legal_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

enum LegalDocumentType { terms, privacy }

class LegalScreen extends ConsumerStatefulWidget {
  const LegalScreen({required this.type, super.key});

  final LegalDocumentType type;

  @override
  ConsumerState<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends ConsumerState<LegalScreen> {
  // Bumped to force a fresh InAppWebView (re-running initialData) on retry.
  Key _webViewKey = UniqueKey();

  LegalDocumentType get type => widget.type;

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(legalScreenUiViewModelProvider(type));
    final l10n = AppLocalizations.of(context);
    final title = type == LegalDocumentType.terms
        ? l10n.termsOfServiceTitle
        : l10n.privacyPolicyTitle;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          useNativeToolbar: false,
          leading: IconButton(
            tooltip: l10n.goBackTooltip,
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.adaptive.arrow_back_rounded,
                size: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          title: title,
        ),
        body: MaxWidthContainer(
          maxWidth: kMaxWidthWide,
          child: Stack(
            children: [
              InAppWebView(
                key: _webViewKey,
                initialData: InAppWebViewInitialData(
                  data: _buildHtmlContent(
                    title,
                    type,
                    Localizations.localeOf(context).languageCode,
                  ),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: false,
                  disableContextMenu: true,
                  useOnLoadResource: false,
                ),
                onLoadStop: (controller, url) {
                  // Late async callback: the widget (and its autoDispose
                  // provider) may already be gone after the user taps back.
                  if (!mounted) return;
                  ref
                      .read(legalScreenUiViewModelProvider(type).notifier)
                      .setLoading(false);
                },
                onReceivedError: (controller, request, error) {
                  if (!mounted) return;
                  ref
                      .read(legalScreenUiViewModelProvider(type).notifier)
                      .setError();
                },
              ),
              if (uiState.hasError)
                _LegalErrorView(
                  message: l10n.somethingWentWrong,
                  retryLabel: l10n.tryAgain,
                  onRetry: () {
                    ref
                        .read(legalScreenUiViewModelProvider(type).notifier)
                        .retry();
                    setState(() => _webViewKey = UniqueKey());
                  },
                )
              else if (uiState.isLoading)
                ColoredBox(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          strokeWidth: 2.5,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          type == LegalDocumentType.terms
                              ? l10n.loadingTermsOfService
                              : l10n.loadingPrivacyPolicy,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildHtmlContent(
    String title,
    LegalDocumentType type,
    String langCode,
  ) {
    if (type == LegalDocumentType.privacy) {
      return langCode == 'fr' ? _privacyHtmlDocumentFr : _privacyHtmlDocumentEn;
    }

    const lastUpdated = 'Last updated: February 23, 2026';
    const body = _termsBody;
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      font-size: 15px;
      line-height: 1.7;
      color: #1a1a1a;
      background: #ffffff;
      padding: 24px 20px 48px;
    }
    h1 { font-size: 22px; font-weight: 800; color: #2D6A4F; margin-bottom: 4px; }
    .subtitle { font-size: 12px; color: #888; margin-bottom: 28px; }
    h2 {
      font-size: 16px;
      font-weight: 700;
      color: #2D6A4F;
      margin-top: 28px;
      margin-bottom: 8px;
      padding-left: 12px;
      border-left: 3px solid #40916C;
    }
    p { margin-bottom: 12px; color: #333; }
    ul { padding-left: 20px; margin-bottom: 12px; }
    li { margin-bottom: 6px; color: #333; }
    a { color: #40916C; text-decoration: underline; }
    .highlight {
      background: #E8F5E9;
      border-radius: 10px;
      padding: 14px 16px;
      margin-bottom: 20px;
      font-size: 13px;
      color: #2D6A4F;
    }
  </style>
</head>
<body>
  <h1>$title</h1>
  <p class="subtitle">$lastUpdated · SportConnect</p>
  $body
</body>
</html>
''';
  }

  static const String _termsBody = '''
  <div class="highlight">
    Please read these Terms carefully before using SportConnect. By creating an account
    or using the app, you agree to be bound by these Terms.
  </div>

  <h2>1. Who We Are</h2>
  <p>SportConnect is a social carpooling platform that connects users for shared rides to sporting events, training sessions, and related activities.</p>

  <h2>2. Eligibility</h2>
  <p>You must meet applicable age and legal requirements to use the service. Drivers are responsible for holding a valid licence and complying with transport laws.</p>

  <h2>3. Your Account</h2>
  <ul>
    <li>You are responsible for your account credentials and activity.</li>
    <li>You must provide accurate registration information.</li>
    <li>You may not share your account or impersonate another person.</li>
  </ul>

  <h2>4. Rides and Payments</h2>
  <p>SportConnect facilitates ride coordination and cost sharing. Payments are processed through Stripe, and platform fees may apply.</p>

  <h2>5. Conduct</h2>
  <ul>
    <li>Do not harass, abuse, or endanger other users.</li>
    <li>Do not publish fraudulent or misleading information.</li>
    <li>Do not use the platform for unlawful or unauthorized commercial activity.</li>
  </ul>

  <h2>6. Termination</h2>
  <p>We may suspend or terminate accounts that violate these Terms or applicable law.</p>

  <h2>7. Contact</h2>
  <p>Questions? Contact <a href="mailto:legal@sportconnect.app">legal@sportconnect.app</a>.</p>
''';

  static const String _privacyHtmlDocumentFr = '''
<!doctype html>
<html lang="fr">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Politique de Confidentialité - SportConnect</title>
    <style>
      body {
        font-family:
          -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        max-width: 860px;
        margin: 0 auto;
        padding: 40px 24px;
        color: #1a1a1a;
        line-height: 1.7;
      }
      h1 {
        font-size: 2rem;
        margin-bottom: 4px;
      }
      h2 {
        font-size: 1.25rem;
        margin-top: 40px;
        border-bottom: 1px solid #e0e0e0;
        padding-bottom: 6px;
      }
      h3 {
        font-size: 1rem;
        margin-top: 24px;
      }
      p,
      li {
        font-size: 0.97rem;
      }
      ul {
        padding-left: 20px;
      }
      a {
        color: #0066cc;
      }
      .meta {
        color: #666;
        font-size: 0.9rem;
        margin-bottom: 32px;
      }
      table {
        border-collapse: collapse;
        width: 100%;
        margin: 16px 0;
      }
      th,
      td {
        border: 1px solid #ddd;
        padding: 10px 14px;
        text-align: left;
        font-size: 0.93rem;
      }
      th {
        background: #f5f5f5;
        font-weight: 600;
      }
    </style>
  </head>
  <body>
    <h1>Politique de Confidentialité</h1>
    <p class="meta">
      Application : <strong>SportConnect</strong><br />
      Dernière mise à jour : avril 2026<br />
      Contact :
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>
    </p>

    <p>
      SportConnect (« nous », « notre » ou « nos ») exploite une plateforme de
      covoiturage social destinée aux amateurs de sport. La présente Politique
      de Confidentialité explique quelles données personnelles nous collectons,
      pourquoi nous les collectons, comment nous les utilisons et les partageons,
      et quels droits vous avez sur vos données.
    </p>

    <p>
      En utilisant l'application mobile SportConnect (iOS ou Android), vous
      reconnaissez avoir pris connaissance de la présente politique.
    </p>

    <h2>1. Qui sommes-nous</h2>
    <p>
      SportConnect est exploité par l'éditeur de l'application. Pour toute
      question relative à la confidentialité ou à vos données personnelles,
      contactez-nous :
    </p>
    <ul>
      <li>Téléphone : +33 06 20 18 48 96</li>
      <li>
        Courriel :
        <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>
      </li>
      <li>
        Site web :
        <a href="https://sportaxitrip.com" target="_blank">sportaxitrip.com</a>
      </li>
    </ul>
    <p>
      Nous nous engageons à répondre à toute demande dans un délai de
      <strong>30 jours</strong>.
    </p>

    <h2>2. Données collectées et pourquoi</h2>

    <h3>2.1 Données d'identification et de compte</h3>
    <ul>
      <li>
        <strong>Adresse e-mail</strong> — obligatoire pour créer un compte, se
        connecter et récupérer son accès
      </li>
      <li>
        <strong>Nom et prénom / pseudo</strong> — affiché sur votre profil
        public et dans les conversations
      </li>
      <li>
        <strong>Confirmation d'âge</strong> — vous déclarez avoir au moins 18
        ans lors de la création de votre compte ; nous ne vérifions pas cette
        information de manière indépendante via une pièce d'identité ou une
        date de naissance lors de l'inscription
      </li>
      <li>
        <strong>Date de naissance</strong> — facultative ; vous pouvez
        l'ajouter ultérieurement dans votre profil
      </li>
      <li>
        <strong>Genre</strong> — facultatif ; utilisé pour activer la préférence
        « trajets réservés aux femmes »
      </li>
      <li>
        <strong>Numéro de téléphone</strong> — facultatif ; utilisé pour la
        vérification d'identité et la coordination de trajets
      </li>
      <li>
        <strong>Adresse</strong> — facultative ; si renseignée, utilisée pour
        personnaliser les suggestions de trajets et d'événements à proximité
        et affichée sur votre profil
      </li>
      <li>
        <strong>Photo de profil</strong> — facultative ; visible par les autres
        utilisateurs
      </li>
      <li>
        <strong>Niveau d'expérience (conduite/pratique)</strong> — par défaut
        « Débutant », modifiable à tout moment ; utilisé uniquement pour la
        personnalisation de l'inscription, pas pour la mise en relation
      </li>
      <li>
        <strong>Mot de passe</strong> — stocké sous forme hachée par Firebase
        Authentication ; nous ne stockons jamais les mots de passe en clair
      </li>
    </ul>
    <p>
      Vous pouvez également vous connecter via
      <strong>Google Sign-In</strong> ou <strong>Apple Sign-In</strong>. Dans ce
      cas, nous recevons votre nom, adresse e-mail et photo de profil de ces
      fournisseurs. Nous ne recevons pas votre mot de passe Google ou Apple.
    </p>

    <h3>2.2 Données spécifiques aux conducteurs</h3>
    <p>
      Les utilisateurs s'inscrivant en tant que conducteurs fournissent en outre
      :
    </p>
    <ul>
      <li>Marque, modèle, année, couleur, immatriculation et capacité</li>
      <li>Photo du véhicule, statut actif et véhicule par défaut</li>
      <li>
        Informations d'identité et bancaires requises par Stripe pour les
        virements (voir section 4)
      </li>
    </ul>

    <h3>2.3 Données de localisation</h3>
    <p>
      La localisation est au cœur du fonctionnement de SportConnect. Nous
      collectons deux types de données de localisation :
    </p>

    <table>
      <tr>
        <th>Type</th>
        <th>Moment de collecte</th>
        <th>Finalité</th>
      </tr>
      <tr>
        <td><strong>Localisation en premier plan</strong></td>
        <td>Lorsque vous utilisez activement l'application</td>
        <td>
          Afficher votre position sur la carte, trouver des trajets à proximité,
          calculer les distances, afficher les événements proches
        </td>
      </tr>
      <tr>
        <td><strong>Localisation pendant un trajet actif</strong></td>
        <td>
          Lorsque vous utilisez l'application pendant un trajet actif
        </td>
        <td>
          Afficher la progression du trajet, aider à coordonner les
          participants et faciliter la confirmation d'arrivée aux points de
          prise en charge et de dépose
        </td>
      </tr>
    </table>

    <p>
      <strong>Localisation pendant les trajets.</strong> SportConnect demande
      uniquement l'autorisation de localisation « lorsque l'application est
      utilisée ». L'application ne demande pas l'autorisation de localisation
      permanente. Votre localisation est utilisée lorsque vous utilisez
      l'application pour afficher les trajets proches, montrer la progression du
      trajet et aider à coordonner les participants. Elle n'est jamais utilisée
      pour de la publicité ou de l'analyse comportementale.
    </p>

    <p>
      Vous pouvez révoquer l'autorisation de localisation à tout moment dans les
      Paramètres de votre appareil. Sans cette autorisation, certaines fonctions
      de carte et de coordination de trajet peuvent être limitées.
    </p>

    <p>
      Les conversions d'adresses en coordonnées GPS sont traitées via l'<strong
        >API Nominatim</strong
      >
      de l'OpenStreetMap Foundation. Vos requêtes de recherche d'adresses sont
      transmises à leurs serveurs, conformément à leur
      <a href="https://osmfoundation.org/wiki/Privacy_Policy" target="_blank"
        >politique de confidentialité</a
      >.
    </p>

    <p>
      Lorsque vous partagez votre position dans une conversation, les
      coordonnées sont converties en adresse lisible via le service de
      cartographie intégré à votre appareil (Apple Maps sur iOS, Google Maps
      sur Android), qui peut faire appel à ses propres serveurs, en complément
      du service Nominatim utilisé pour la recherche d'adresses.
    </p>

    <h3>2.4 Données de trajets et d'événements</h3>
    <ul>
      <li>Adresses et coordonnées de départ et d'arrivée</li>
      <li>Horaires de départ et d'arrivée prévus</li>
      <li>
        Nombre de places, tarif par place, préférences (bagages, animaux, tabac,
        femmes uniquement)
      </li>
      <li>Historique de réservations et statut des trajets</li>
      <li>
        Titre, description, lieu, horaires, liste des participants et trajets
        associés d'un événement
      </li>
    </ul>

    <h3>2.5 Données de paiement et financières</h3>
    <p>
      Tous les paiements sont traités par <strong>Stripe</strong> (Stripe, Inc.
      et ses filiales). Nous ne stockons pas les numéros de carte bancaire
      complets sur nos serveurs.
    </p>

    <p><strong>Pour les passagers :</strong></p>
    <ul>
      <li>
        Stripe stocke vos moyens de paiement (type de carte, 4 derniers
        chiffres, date d'expiration, pays)
      </li>
      <li>
        Nous stockons votre identifiant client Stripe et les enregistrements de
        transactions (montants, horodatages, statuts)
      </li>
    </ul>

    <p><strong>Pour les conducteurs :</strong></p>
    <ul>
      <li>
        Les conducteurs créent un compte Stripe Connect. Stripe collecte et
        stocke les informations d'identité et bancaires requises (nom, date de
        naissance, adresse, numéro fiscal, IBAN). Nous ne stockons pas ces
        informations sur nos serveurs — elles sont détenues par Stripe
        conformément à leur
        <a href="https://stripe.com/fr/privacy" target="_blank"
          >politique de confidentialité</a
        >.
      </li>
      <li>
        Nous stockons votre identifiant de compte Stripe Connect, l'historique
        des virements et le résumé des gains
      </li>
    </ul>

    <p>
      <strong>Abonnements premium :</strong> SportConnect propose un abonnement
      premium optionnel (4,99 €/mois ou 49,99 €/an) traité entièrement via
      l'App Store d'Apple ou Google Play. Nous ne recevons pas vos coordonnées
      bancaires pour les abonnements. La gestion de la facturation est assurée
      par Apple ou Google selon la plateforme utilisée.
    </p>

    <p>
      <strong>Frais de plateforme :</strong> Un pourcentage est prélevé sur
      chaque transaction de trajet avant le virement au conducteur. Ce montant
      est indiqué dans l'application au moment de la réservation.
    </p>

    <h3>2.6 Données de messagerie et de chat</h3>
    <p>
      SportConnect inclut une messagerie intégrée entre utilisateurs. Les
      éléments suivants sont stockés sur nos serveurs :
    </p>
    <ul>
      <li>
        Messages texte dans les conversations privées, de groupe trajet et de
        groupe événement
      </li>
      <li>
        Images partagées dans les conversations (stockées dans Firebase Storage)
      </li>
      <li>
        Messages de localisation (coordonnées que vous choisissez de partager
        manuellement dans une conversation)
      </li>
      <li>
        Métadonnées de message : expéditeur, horodatage, statut de livraison,
        accusés de lecture, réactions
      </li>
    </ul>
    <p>
      Les messages sont visibles par tous les participants de la conversation
      concernée. Le contenu des messages n'est pas utilisé à des fins
      publicitaires. Vous pouvez supprimer des messages individuels ou effacer
      votre historique de conversation à tout moment.
    </p>

    <h3>2.7 Caméra et photothèque</h3>
    <p>L'accès à la caméra et à la photothèque est demandé pour :</p>
    <ul>
      <li>Télécharger une photo de profil</li>
      <li>Télécharger les photos et documents du véhicule (conducteurs)</li>
      <li>Télécharger une image de couverture d'événement</li>
      <li>Partager des images dans le chat</li>
      <li>Joindre des pièces justificatives à un litige</li>
    </ul>
    <p>
      Les photos sont téléchargées vers Firebase Storage (Google Cloud) et
      associées à votre compte. Nous n'analysons pas le contenu des photos
      au-delà du stockage et de la livraison.
    </p>

    <h3>2.8 Données d'utilisation et de diagnostic</h3>
    <ul>
      <li>
        <strong>Firebase Analytics</strong> — statistiques d'utilisation
        anonymes (écrans consultés, fonctionnalités utilisées, durée de
        session). Ces données sont associées à un identifiant analytique généré
        aléatoirement, non à votre nom ou e-mail.
      </li>
      <li>
        <strong>Firebase Crashlytics</strong> — rapports d'erreurs et traces de
        pile lorsque l'application plante. Inclut le modèle d'appareil, la
        version du système d'exploitation, la version de l'application et la
        séquence d'événements ayant précédé le plantage. Aucun contenu de
        message ni donnée de paiement n'est inclus dans les rapports de
        plantage.
      </li>
      <li>
        <strong>Jeton FCM</strong> — jeton spécifique à l'appareil utilisé pour
        la livraison des notifications push. Stocké sur nos serveurs et supprimé
        lors de la déconnexion ou de la désinstallation de l'application.
      </li>
    </ul>
    <p>
      Les données analytiques et les rapports de plantage sont utilisés pour
      améliorer la fiabilité de l'application et ne sont pas utilisés à des
      fins publicitaires.
    </p>

    <h3>2.9 Avis, évaluations et gamification</h3>
    <ul>
      <li>
        Notes et avis écrits que vous soumettez sur d'autres utilisateurs
        (publiés sur leur profil)
      </li>
      <li>Notes et avis que d'autres utilisateurs soumettent à votre sujet</li>
      <li>
        Données de gamification : points XP, niveau, succès débloqués, séries de
        trajets, classement
      </li>
    </ul>

    <h3>2.11 Données de support et de litige</h3>
    <ul>
      <li>
        Descriptions de litiges, pièces justificatives (images, PDF) et statut
        du litige
      </li>
      <li>Messages de support et historique des échanges avec notre équipe</li>
    </ul>

    <h2>3. Pourquoi nous utilisons vos données</h2>
    <table>
      <tr>
        <th>Utilisation</th>
        <th>Raison</th>
      </tr>
      <tr>
        <td>Création de compte et authentification</td>
        <td>Nécessaire pour fournir le service</td>
      </tr>
      <tr>
        <td>Mise en relation et coordination de trajets</td>
        <td>Nécessaire pour fournir le service</td>
      </tr>
      <tr>
        <td>Traitement des paiements et virements conducteurs</td>
        <td>Nécessaire pour fournir le service et respecter nos obligations légales de conservation comptable</td>
      </tr>
      <tr>
        <td>Localisation pendant les trajets actifs</td>
        <td>Nécessaire pour afficher et coordonner le trajet en temps réel</td>
      </tr>
      <tr>
        <td>Analytique et rapports de plantage</td>
        <td>Améliorer la fiabilité et les performances de l'application</td>
      </tr>
      <tr>
        <td>Notifications push</td>
        <td>Avec votre consentement — révocable à tout moment dans les Paramètres</td>
      </tr>
      <tr>
        <td>Gestion de l'abonnement premium</td>
        <td>Nécessaire pour fournir les fonctionnalités premium souscrites</td>
      </tr>
      <tr>
        <td>Conservation des données financières</td>
        <td>Nos obligations légales de conservation des documents comptables (10 ans)</td>
      </tr>
      <tr>
        <td>Vérification de l'âge (18 ans minimum)</td>
        <td>Conformité à nos conditions d'utilisation et à la réglementation applicable</td>
      </tr>
    </table>

    <h2>4. Avec qui nous partageons vos données</h2>

    <h3>4.1 Autres utilisateurs de l'application</h3>
    <ul>
      <li>
        Votre nom, photo de profil, note et avis sont visibles par les autres
        utilisateurs de SportConnect
      </li>
      <li>
        Votre adresse de départ/arrivée est visible par le conducteur et les
        passagers confirmés d'un trajet
      </li>
      <li>
        Les messages du chat sont visibles par tous les participants de la
        conversation concernée
      </li>
      <li>
        Votre adresse e-mail et vos données de paiement ne sont
        <strong>jamais</strong> partagées avec d'autres utilisateurs
      </li>
    </ul>

    <h3>4.2 Prestataires de services</h3>
    <p>
      Nous faisons appel aux prestataires suivants pour exploiter la plateforme.
      Chacun est soumis à ses propres engagements de confidentialité :
    </p>
    <table>
      <tr>
        <th>Prestataire</th>
        <th>Service</th>
        <th>Données transmises</th>
        <th>Localisation des serveurs</th>
        <th>Politique de confidentialité</th>
      </tr>
      <tr>
        <td>Google (Firebase)</td>
        <td>
          Infrastructure backend, authentification, analytique, rapports de
          plantage, notifications push, stockage
        </td>
        <td>Toutes les données de l'application stockées sur Google Cloud</td>
        <td>
          Union Européenne (europe-west1) et potentiellement d'autres régions
        </td>
        <td>
          <a href="https://policies.google.com/privacy?hl=fr" target="_blank"
            >policies.google.com/privacy</a
          >
        </td>
      </tr>
      <tr>
        <td>Stripe</td>
        <td>Traitement des paiements et virements conducteurs</td>
        <td>Moyens de paiement, transactions, identité du conducteur</td>
        <td>États-Unis et UE</td>
        <td>
          <a href="https://stripe.com/fr/privacy" target="_blank"
            >stripe.com/fr/privacy</a
          >
        </td>
      </tr>
      <tr>
        <td>Apple</td>
        <td>Apple Sign-In, abonnements App Store, notifications push</td>
        <td>Jeton d'identité, statut d'abonnement</td>
        <td>États-Unis et UE</td>
        <td>
          <a href="https://www.apple.com/fr/legal/privacy/" target="_blank"
            >apple.com/fr/legal/privacy</a
          >
        </td>
      </tr>
      <tr>
        <td>Google (Sign-In)</td>
        <td>Connexion via Google</td>
        <td>E-mail, nom, photo de profil</td>
        <td>États-Unis et UE</td>
        <td>
          <a href="https://policies.google.com/privacy?hl=fr" target="_blank"
            >policies.google.com/privacy</a
          >
        </td>
      </tr>
      <tr>
        <td>OpenStreetMap Foundation (Nominatim)</td>
        <td>Géocodage d'adresses</td>
        <td>Requêtes de recherche d'adresses</td>
        <td>Pays-Bas</td>
        <td>
          <a
            href="https://osmfoundation.org/wiki/Privacy_Policy"
            target="_blank"
            >osmfoundation.org</a
          >
        </td>
      </tr>
    </table>

    <h3>4.3 Divulgation légale</h3>
    <p>
      Nous pouvons divulguer vos données si la loi l'exige, sur ordonnance
      judiciaire, ou pour protéger les droits et la sécurité de nos utilisateurs
      ou du public.
    </p>

    <h3>4.4 Pas de vente de données personnelles</h3>
    <p>
      Nous ne vendons, ne louons ni n'échangeons vos données personnelles avec
      des tiers à des fins de marketing ou de publicité.
    </p>

    <h2>5. Transferts de données internationaux</h2>
    <p>
      Certains de nos prestataires (notamment Stripe et Google) peuvent traiter
      vos données aux États-Unis ou dans d'autres pays. Ces transferts sont
      encadrés par des garanties appropriées, notamment les clauses contractuelles
      types approuvées par la Commission européenne et le cadre EU-États-Unis sur
      la protection des données. Vous pouvez obtenir plus d'informations en nous
      contactant à
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.
    </p>

    <h2>6. Politique de remboursement</h2>

    <h3>6.1 Paiements de trajets</h3>
    <p>
      Les paiements de trajets sont traités via Stripe. Les remboursements sont
      soumis aux règles suivantes :
    </p>
    <ul>
      <li>
        <strong>Trajet annulé par le conducteur avant le départ :</strong>
        remboursement intégral automatique sous 5 à 10 jours ouvrés sur le moyen
        de paiement d'origine.
      </li>
      <li>
        <strong>Trajet annulé par le passager :</strong> l'éligibilité au
        remboursement dépend du délai de préavis à la date d'annulation, tel
        qu'indiqué dans l'application au moment de la réservation. Les
        annulations effectuées avec un préavis suffisant peuvent donner droit à
        un remboursement total ou partiel.
      </li>
      <li>
        <strong>Trajet non effectué conformément aux attentes :</strong>
        les cas vérifiables, comme une absence du conducteur 30 minutes après
        l'heure de départ prévue, sont traités automatiquement dans
        l'application. Les autres désaccords doivent être signalés via la
        fonctionnalité de litige intégrée dans les <strong>30 jours</strong>
        suivant le trajet.
      </li>
      <li>
        <strong>Contestation de prélèvement :</strong> utilisez la
        fonctionnalité de litige intégrée à l'application ou contactez le
        support. Les litiges doivent être soumis dans les
        <strong>30 jours</strong> suivant la transaction.
      </li>
    </ul>

    <h3>6.2 Abonnements premium</h3>
    <p>
      Les abonnements premium sont achetés via l'<strong
        >App Store d'Apple</strong
      >
      ou le <strong>Google Play Store</strong>. Les remboursements d'abonnements
      sont gérés directement par Apple ou Google :
    </p>
    <ul>
      <li>
        <strong>App Store Apple :</strong> demandez un remboursement sur
        <a href="https://reportaproblem.apple.com" target="_blank"
          >reportaproblem.apple.com</a
        >.
      </li>
      <li>
        <strong>Google Play Store :</strong> demandez un remboursement via
        l'application Google Play.
      </li>
    </ul>
    <p>
      Nous ne pouvons pas émettre de remboursement pour les achats intégrés en
      votre nom — toute la facturation et les remboursements d'abonnements sont
      gérés par Apple ou Google. Vous pouvez résilier votre abonnement à tout
      moment dans les paramètres d'abonnement de votre appareil ; la résiliation
      prend effet à la fin de la période de facturation en cours.
    </p>

    <h2>7. Durée de conservation des données</h2>
    <table>
      <tr>
        <th>Type de données</th>
        <th>Durée de conservation</th>
      </tr>
      <tr>
        <td>Compte et données de profil</td>
        <td>Jusqu'à la suppression du compte</td>
      </tr>
      <tr>
        <td>Historique de trajets</td>
        <td>
          Conservé à des fins d'audit et de résolution de litiges, même après
          suppression du compte
        </td>
      </tr>
      <tr>
        <td>Enregistrements de transactions de paiement</td>
        <td>
          <strong>10 ans</strong> — durée légale de conservation des documents
          comptables
        </td>
      </tr>
      <tr>
        <td>Messages de chat</td>
        <td>
          Jusqu'à leur suppression par l'utilisateur ou la suppression du compte
        </td>
      </tr>
      <tr>
        <td>Images</td>
        <td>Jusqu'à la suppression du message ou du compte associé</td>
      </tr>
      <tr>
        <td>Localisation pendant les trajets actifs</td>
        <td>
          Conservée uniquement selon les besoins de fonctionnement du trajet et
          les réglages de votre compte
        </td>
      </tr>
      <tr>
        <td>Données analytiques</td>
        <td>
          Selon les paramètres de rétention de Google Analytics (14 mois par
          défaut)
        </td>
      </tr>
      <tr>
        <td>Rapports de plantage</td>
        <td>90 jours (paramètre par défaut de Firebase Crashlytics)</td>
      </tr>
      <tr>
        <td>Jetons de notification push (FCM)</td>
        <td>Jusqu'à la déconnexion ou la désinstallation de l'application</td>
      </tr>
      <tr>
        <td>Documents de litige et de support</td>
        <td>5 ans après clôture du dossier</td>
      </tr>
    </table>

    <h2>8. Vos droits</h2>
    <p>
      Vous avez les droits suivants sur vos données personnelles :
    </p>
    <ul>
      <li>
        <strong>Accès :</strong> obtenir une copie des données personnelles que
        nous détenons sur vous
      </li>
      <li>
        <strong>Rectification :</strong> corriger des données inexactes ou
        incomplètes (la plupart des champs sont modifiables directement dans
        l'application)
      </li>
      <li>
        <strong>Suppression :</strong> supprimer votre compte et vos données via
        l'option « Supprimer mon compte » dans les Paramètres, ou via notre
        <a href="https://sportaxitrip.com/delete-account.html">formulaire en ligne</a>.
        Voir section 9 pour le détail.
      </li>
      <li>
        <strong>Portabilité :</strong> recevoir vos données dans un format
        structuré et lisible par machine
      </li>
      <li>
        <strong>Limitation :</strong> demander la limitation du traitement de
        vos données dans certaines circonstances
      </li>
      <li>
        <strong>Opposition :</strong> vous opposer à l'utilisation de vos
        données à des fins d'analytique ou d'amélioration du service
      </li>
      <li>
        <strong>Retrait du consentement :</strong> retirer votre consentement
        aux notifications push ou à l'analytique à tout moment dans les
        Paramètres de l'application
      </li>
    </ul>
    <p>
      Pour exercer l'un de ces droits, contactez-nous à
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.
      Nous vous répondrons dans un délai de <strong>30 jours</strong>.
    </p>

    <h2>9. Suppression de compte</h2>
    <p>
      Vous pouvez supprimer votre compte à tout moment depuis :
      <strong>Paramètres → Compte → Supprimer mon compte</strong> dans
      l'application, ou via notre
      <a href="https://sportaxitrip.com/delete-account.html">formulaire web de suppression</a>.
    </p>

    <p><strong>Données supprimées lors de la clôture du compte :</strong></p>
    <ul>
      <li>
        Profil, informations de compte, photo de profil et image de couverture
      </li>
      <li>Tous les trajets créés en qualité de conducteur</li>
      <li>Toutes les réservations effectuées en qualité de passager</li>
      <li>
        Votre accès de connexion Google et/ou Apple est révoqué, en plus de la
        suppression de votre compte SportConnect
      </li>
      <li>
        Votre profil client Stripe (moyens de paiement) est supprimé. Votre
        compte Stripe Connect conducteur est clôturé une fois votre solde
        entièrement réglé et en l'absence de litige en cours ; si un virement
        ou un litige est en attente, la clôture intervient une fois celui-ci
        résolu, conformément aux exigences de notre prestataire de paiement
      </li>
      <li>Tous les avis rédigés sur d'autres utilisateurs</li>
      <li>Tous les messages envoyés</li>
      <li>Informations de véhicule et documents associés</li>
      <li>
        Participation à l'ensemble des conversations, événements et
        notifications
      </li>
    </ul>
    <p><strong>Données conservées après la clôture du compte :</strong></p>
    <ul>
      <li>
        Les avis rédigés par d'autres utilisateurs à votre sujet, conservés sous
        forme anonymisée afin de préserver l'intégrité de la plateforme
      </li>
      <li>
        Les enregistrements de transactions de paiement, conservés pendant 10 ans
        conformément aux exigences légales de conservation comptable
      </li>
      <li>
        Les enregistrements de trajets impliquant d'autres participants,
        conservés aux fins de résolution de litiges éventuels
      </li>
    </ul>

    <p>
      <strong>Remarque :</strong> La suppression de compte est bloquée si vous
      avez un trajet en cours. Terminez ou annulez le trajet avant de demander
      la suppression.
    </p>

    <h2>10. Mineurs</h2>
    <p>
      SportConnect n'est pas destiné aux personnes âgées de moins de 18 ans.
      Vous devez confirmer avoir au moins 18 ans lors de la création de votre
      compte ; il s'agit d'une déclaration sur l'honneur, non vérifiée de
      manière indépendante via une pièce d'identité ou une date de naissance.
      Si nous constatons qu'un utilisateur de moins de 18 ans a créé un
      compte, nous le supprimerons dans les meilleurs délais. Si vous pensez
      qu'un mineur s'est inscrit, contactez-nous à
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.
    </p>

    <h2>11. Notifications push</h2>
    <p>
      Nous envoyons des notifications push pour les mises à jour de trajets, les
      nouveaux messages, les confirmations de réservation et les activités de
      compte. Votre <strong>consentement explicite</strong> est recueilli avant
      l'envoi de toute notification. Vous pouvez :
    </p>
    <ul>
      <li>
        Désactiver toutes les notifications dans Paramètres de l'appareil →
        Notifications → SportConnect
      </li>
      <li>
        Contrôler les types de notifications individuels dans l'application sous
        Paramètres → Notifications
      </li>
      <li>
        Définir des heures calmes pour bloquer les notifications pendant
        certaines plages horaires
      </li>
    </ul>

    <h2>12. Sécurité des données</h2>
    <p>
      Nous mettons en œuvre les mesures de sécurité suivantes pour protéger vos
      données :
    </p>
    <ul>
      <li>
        Chiffrement de toutes les communications entre l'application et nos
        serveurs via HTTPS/TLS
      </li>
      <li>
        Gestion des mots de passe hachés et sessions basées sur des jetons via
        Firebase Authentication
      </li>
      <li>
        Protection contre les accès non autorisés à l'API via Firebase App Check
      </li>
      <li>
        Traitement des paiements exclusivement via Stripe, certifié PCI DSS
      </li>
      <li>
        Contrôle d'accès aux fichiers Firebase Storage limité aux utilisateurs
        autorisés
      </li>
      <li>
        Re-authentification requise pour les opérations sensibles (paiements,
        suppression de compte)
      </li>
      <li>
        Limitation à 5–10 Mo des fichiers téléchargés selon le type de fichier
      </li>
    </ul>
    <p>
      Aucun système n'est sécurisé à 100 %. Si vous suspectez un accès non
      autorisé à votre compte, changez immédiatement votre mot de passe et
      contactez-nous.
    </p>

    <h2>13. Traceurs analytiques</h2>
    <p>
      L'application mobile SportConnect n'utilise pas de cookies. Les données
      analytiques et de performance sont collectées via les SDK Firebase
      (Google Analytics for Firebase et Firebase Crashlytics). Ces données sont
      utilisées uniquement pour améliorer la fiabilité et l'expérience de
      l'application, et non à des fins publicitaires.
    </p>

    <h2>14. Modifications de la présente politique</h2>
    <p>
      Nous pouvons mettre à jour cette Politique de Confidentialité
      périodiquement. Nous vous informerons de toute modification importante via
      une notification push ou une alerte dans l'application. La date de «
      Dernière mise à jour » en haut de cette page reflète toujours la version
      la plus récente. La poursuite de l'utilisation de l'application après une
      modification vaut acceptation de la politique mise à jour.
    </p>

    <h2>15. Nous contacter</h2>
    <p>
      Pour toute question relative à cette Politique de Confidentialité, pour
      exercer vos droits ou signaler un problème de confidentialité :
    </p>
    <ul>
      <li>
        Courriel :
        <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>
      </li>
      <li>
        Site web :
        <a href="https://sportaxitrip.com" target="_blank">sportaxitrip.com</a>
      </li>
    </ul>

    <hr style="margin-top: 48px; border: none; border-top: 1px solid #e0e0e0" />
    <p style="color: #999; font-size: 0.85rem; text-align: center">
      © 2026 SportConnect. Tous droits réservés.
    </p>
  </body>
</html>
''';

  static const String _privacyHtmlDocumentEn = '''
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Privacy Policy - SportConnect</title>
    <style>
      body {
        font-family:
          -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        max-width: 860px;
        margin: 0 auto;
        padding: 40px 24px;
        color: #1a1a1a;
        line-height: 1.7;
      }
      h1 { font-size: 2rem; margin-bottom: 4px; }
      h2 {
        font-size: 1.25rem;
        margin-top: 40px;
        border-bottom: 1px solid #e0e0e0;
        padding-bottom: 6px;
      }
      h3 { font-size: 1rem; margin-top: 24px; }
      p, li { font-size: 0.97rem; }
      ul { padding-left: 20px; }
      a { color: #0066cc; }
      .meta { color: #666; font-size: 0.9rem; margin-bottom: 32px; }
      table { border-collapse: collapse; width: 100%; margin: 16px 0; }
      th, td {
        border: 1px solid #ddd;
        padding: 10px 14px;
        text-align: left;
        font-size: 0.93rem;
      }
      th { background: #f5f5f5; font-weight: 600; }
    </style>
  </head>
  <body>
    <h1>Privacy Policy</h1>
    <p class="meta">
      App: <strong>SportConnect</strong><br />
      Last updated: April 2026<br />
      Contact:
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>
    </p>

    <p>
      SportConnect ("we", "our", or "us") operates a social carpooling platform
      for sports enthusiasts. This Privacy Policy explains what personal data we
      collect, why we collect it, how we use and share it, and what rights you
      have over your data.
    </p>

    <p>
      By using the SportConnect mobile app (iOS or Android), you acknowledge
      that you have read and understood this policy.
    </p>

    <h2>1. Who We Are</h2>
    <p>
      SportConnect is operated by the app publisher. For any privacy or
      personal data enquiries, please contact us:
    </p>
    <ul>
      <li>Phone: +33 06 20 18 48 96</li>
      <li>
        Email:
        <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>
      </li>
      <li>
        Website:
        <a href="https://sportaxitrip.com" target="_blank">sportaxitrip.com</a>
      </li>
    </ul>
    <p>
      We are committed to responding to any request within
      <strong>30 days</strong>.
    </p>

    <h2>2. Data We Collect and Why</h2>

    <h3>2.1 Identity and Account Data</h3>
    <ul>
      <li>
        <strong>Email address</strong> — required to create an account, sign in,
        and recover access
      </li>
      <li>
        <strong>First name, last name, or username</strong> — displayed on your
        public profile and in conversations
      </li>
      <li>
        <strong>Age confirmation</strong> — you self-declare that you are at
        least 18 years old when creating an account; we do not independently
        verify this via an ID document or date of birth at signup
      </li>
      <li>
        <strong>Date of birth</strong> — optional; you may add this later in
        your profile
      </li>
      <li>
        <strong>Gender</strong> — optional; used to enable the
        "women-only rides" preference
      </li>
      <li>
        <strong>Phone number</strong> — optional; used for identity verification
        and ride coordination
      </li>
      <li>
        <strong>Address</strong> — optional; if provided, used to personalise
        nearby-ride and nearby-event suggestions and displayed on your profile
      </li>
      <li>
        <strong>Profile photo</strong> — optional; visible to other users
      </li>
      <li>
        <strong>Riding/driving experience level</strong> — defaults to
        "Rookie" and can be changed at any time; used for onboarding
        personalisation only, not for ride matching
      </li>
      <li>
        <strong>Password</strong> — stored in hashed form by Firebase
        Authentication; we never store passwords in plain text
      </li>
    </ul>
    <p>
      You may also sign in via <strong>Google Sign-In</strong> or
      <strong>Apple Sign-In</strong>. In that case, we receive your name, email
      address, and profile photo from those providers. We do not receive your
      Google or Apple password.
    </p>

    <h3>2.2 Driver-Specific Data</h3>
    <p>Users registering as drivers also provide:</p>
    <ul>
      <li>Vehicle make, model, year, colour, licence plate, and capacity</li>
      <li>Vehicle photo, active status, and default vehicle status</li>
      <li>
        Identity and banking information required by Stripe for payouts
        (see section 4)
      </li>
    </ul>

    <h3>2.3 Location Data</h3>
    <p>
      Location is central to how SportConnect works. We collect two types of
      location data:
    </p>

    <table>
      <tr>
        <th>Type</th>
        <th>When collected</th>
        <th>Purpose</th>
      </tr>
      <tr>
        <td><strong>Foreground location</strong></td>
        <td>While you are actively using the app</td>
        <td>
          Show your position on the map, find nearby rides, calculate distances,
          display nearby events
        </td>
      </tr>
      <tr>
        <td><strong>Active ride location</strong></td>
        <td>
          While you use the app during an active ride
        </td>
        <td>
          Show live trip progress, help coordinate participants, and support
          arrival confirmation at pickup and drop-off points
        </td>
      </tr>
    </table>

    <p>
      <strong>Ride location.</strong> SportConnect requests only the "When In
      Use" location permission. The app does not request Always location.
      Location is used while you use the app to show nearby rides, display live
      trip progress, and help coordinate participants. It is never used for
      advertising or behavioural analysis.
    </p>

    <p>
      You can revoke the location permission at any time in your device
      Settings. Without this permission, some map and ride coordination features
      may be limited.
    </p>

    <p>
      Address-to-GPS coordinate conversions are processed via the
      <strong>Nominatim API</strong> from the OpenStreetMap Foundation. Your
      address search queries are sent to their servers in accordance with their
      <a href="https://osmfoundation.org/wiki/Privacy_Policy" target="_blank"
        >privacy policy</a>.
    </p>

    <p>
      When you share your location in a chat conversation, the coordinates are
      converted into a readable address using your device's built-in mapping
      service (Apple Maps on iOS, Google Maps on Android), which may involve
      their own servers, in addition to the Nominatim service used for address
      search.
    </p>

    <h3>2.4 Ride and Event Data</h3>
    <ul>
      <li>Pickup and drop-off addresses and coordinates</li>
      <li>Scheduled departure and arrival times</li>
      <li>
        Number of seats, price per seat, preferences (luggage, pets, smoking,
        women-only)
      </li>
      <li>Booking history and ride status</li>
      <li>
        Event title, description, venue, times, participant list, and associated
        rides
      </li>
    </ul>

    <h3>2.5 Payment and Financial Data</h3>
    <p>
      All payments are processed by <strong>Stripe</strong> (Stripe, Inc. and
      its affiliates). We do not store full card numbers on our servers.
    </p>

    <p><strong>For passengers:</strong></p>
    <ul>
      <li>
        Stripe stores your payment methods (card type, last 4 digits, expiry
        date, country)
      </li>
      <li>
        We store your Stripe customer ID and transaction records (amounts,
        timestamps, statuses)
      </li>
    </ul>

    <p><strong>For drivers:</strong></p>
    <ul>
      <li>
        Drivers create a Stripe Connect account. Stripe collects and stores the
        required identity and banking information (name, date of birth, address,
        tax number, IBAN). We do not store this information on our servers — it
        is held by Stripe in accordance with their
        <a href="https://stripe.com/privacy" target="_blank"
          >privacy policy</a>.
      </li>
      <li>
        We store your Stripe Connect account ID, payout history, and earnings
        summary
      </li>
    </ul>

    <p>
      <strong>Premium subscriptions:</strong> SportConnect offers an optional
      premium subscription (€4.99/month or €49.99/year) processed entirely
      through the Apple App Store or Google Play. We do not receive your payment
      details for subscriptions. Billing is managed by Apple or Google depending
      on your platform.
    </p>

    <p>
      <strong>Platform fee:</strong> A percentage is deducted from each ride
      transaction before the payout to the driver. This amount is shown in the
      app at the time of booking.
    </p>

    <h3>2.6 Messaging and Chat Data</h3>
    <p>
      SportConnect includes in-app messaging between users. The following are
      stored on our servers:
    </p>
    <ul>
      <li>
        Text messages in private, ride group, and event group conversations
      </li>
      <li>Images shared in conversations (stored in Firebase Storage)</li>
      <li>
        Location messages (coordinates you choose to share manually in a
        conversation)
      </li>
      <li>
        Message metadata: sender, timestamp, delivery status, read receipts,
        reactions
      </li>
    </ul>
    <p>
      Messages are visible to all participants in the relevant conversation.
      Message content is not used for advertising purposes. You can delete
      individual messages or clear your conversation history at any time.
    </p>

    <h3>2.7 Camera and Photo Library</h3>
    <p>Camera and photo library access is requested to:</p>
    <ul>
      <li>Upload a profile photo</li>
      <li>Upload vehicle photos and documents (drivers)</li>
      <li>Upload an event cover image</li>
      <li>Share images in chat</li>
      <li>Attach supporting documents to a dispute</li>
    </ul>
    <p>
      Photos are uploaded to Firebase Storage (Google Cloud) and linked to your
      account. We do not analyse photo content beyond storage and delivery.
    </p>

    <h3>2.8 Usage and Diagnostic Data</h3>
    <ul>
      <li>
        <strong>Firebase Analytics</strong> — anonymous usage statistics
        (screens viewed, features used, session duration). This data is
        associated with a randomly generated analytics identifier, not your
        name or email.
      </li>
      <li>
        <strong>Firebase Crashlytics</strong> — error reports and stack traces
        when the app crashes. Includes device model, OS version, app version,
        and the event sequence preceding the crash. No message content or
        payment data is included in crash reports.
      </li>
      <li>
        <strong>FCM token</strong> — a device-specific token used for push
        notification delivery. Stored on our servers and deleted on logout or
        app uninstall.
      </li>
    </ul>
    <p>
      Analytics and crash reports are used to improve app reliability and are
      not used for advertising.
    </p>

    <h3>2.9 Ratings, Reviews, and Gamification</h3>
    <ul>
      <li>
        Ratings and written reviews you submit about other users (published on
        their profile)
      </li>
      <li>Ratings and reviews other users submit about you</li>
      <li>
        Gamification data: XP points, level, unlocked achievements, ride
        streaks, leaderboard
      </li>
    </ul>

    <h3>2.11 Support and Dispute Data</h3>
    <ul>
      <li>
        Dispute descriptions, supporting documents (images, PDFs), and dispute
        status
      </li>
      <li>Support messages and exchange history with our team</li>
    </ul>

    <h2>3. Why We Use Your Data</h2>
    <table>
      <tr>
        <th>Use</th>
        <th>Reason</th>
      </tr>
      <tr>
        <td>Account creation and authentication</td>
        <td>Necessary to provide the service</td>
      </tr>
      <tr>
        <td>Ride matching and coordination</td>
        <td>Necessary to provide the service</td>
      </tr>
      <tr>
        <td>Payment processing and driver payouts</td>
        <td>Necessary to provide the service and meet our legal accounting
        retention obligations</td>
      </tr>
      <tr>
        <td>Location during active rides</td>
        <td>Necessary to advance ride status in real time</td>
      </tr>
      <tr>
        <td>Analytics and crash reporting</td>
        <td>To improve app reliability and performance</td>
      </tr>
      <tr>
        <td>Push notifications</td>
        <td>With your consent — revocable at any time in Settings</td>
      </tr>
      <tr>
        <td>Premium subscription management</td>
        <td>Necessary to provide the subscribed premium features</td>
      </tr>
      <tr>
        <td>Financial data retention</td>
        <td>Our legal obligation to retain accounting records (10 years)</td>
      </tr>
      <tr>
        <td>Age verification (18+ minimum)</td>
        <td>Compliance with our Terms of Service and applicable law</td>
      </tr>
    </table>

    <h2>4. Who We Share Your Data With</h2>

    <h3>4.1 Other App Users</h3>
    <ul>
      <li>
        Your name, profile photo, rating, and reviews are visible to other
        SportConnect users
      </li>
      <li>
        Your pickup/drop-off address is visible to the driver and confirmed
        passengers of a ride
      </li>
      <li>
        Chat messages are visible to all participants in the relevant
        conversation
      </li>
      <li>
        Your email address and payment details are <strong>never</strong> shared
        with other users
      </li>
    </ul>

    <h3>4.2 Service Providers</h3>
    <p>
      We use the following providers to operate the platform. Each is bound by
      its own privacy commitments:
    </p>
    <table>
      <tr>
        <th>Provider</th>
        <th>Service</th>
        <th>Data transmitted</th>
        <th>Server location</th>
        <th>Privacy policy</th>
      </tr>
      <tr>
        <td>Google (Firebase)</td>
        <td>
          Backend infrastructure, authentication, analytics, crash reporting,
          push notifications, storage
        </td>
        <td>All app data stored on Google Cloud</td>
        <td>European Union (europe-west1) and potentially other regions</td>
        <td>
          <a href="https://policies.google.com/privacy" target="_blank"
            >policies.google.com/privacy</a>
        </td>
      </tr>
      <tr>
        <td>Stripe</td>
        <td>Payment processing and driver payouts</td>
        <td>Payment methods, transactions, driver identity</td>
        <td>USA and EU</td>
        <td>
          <a href="https://stripe.com/privacy" target="_blank"
            >stripe.com/privacy</a>
        </td>
      </tr>
      <tr>
        <td>Apple</td>
        <td>Apple Sign-In, App Store subscriptions, push notifications</td>
        <td>Identity token, subscription status</td>
        <td>USA and EU</td>
        <td>
          <a href="https://www.apple.com/legal/privacy/" target="_blank"
            >apple.com/legal/privacy</a>
        </td>
      </tr>
      <tr>
        <td>Google (Sign-In)</td>
        <td>Sign in with Google</td>
        <td>Email, name, profile photo</td>
        <td>USA and EU</td>
        <td>
          <a href="https://policies.google.com/privacy" target="_blank"
            >policies.google.com/privacy</a>
        </td>
      </tr>
      <tr>
        <td>OpenStreetMap Foundation (Nominatim)</td>
        <td>Address geocoding</td>
        <td>Address search queries</td>
        <td>Netherlands</td>
        <td>
          <a href="https://osmfoundation.org/wiki/Privacy_Policy" target="_blank"
            >osmfoundation.org</a>
        </td>
      </tr>
    </table>

    <h3>4.3 Legal Disclosure</h3>
    <p>
      We may disclose your data if required by law, court order, or to protect
      the rights and safety of our users or the public.
    </p>

    <h3>4.4 No Sale of Personal Data</h3>
    <p>
      We do not sell, rent, or trade your personal data with third parties for
      marketing or advertising purposes.
    </p>

    <h2>5. International Data Transfers</h2>
    <p>
      Some of our providers (including Stripe and Google) may process your data
      in the United States or other countries. These transfers are governed by
      appropriate safeguards, including standard contractual clauses approved by
      the European Commission and the EU–US Data Privacy Framework. You can
      obtain more information by contacting us at
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.
    </p>

    <h2>6. Refund Policy</h2>

    <h3>6.1 Ride Payments</h3>
    <p>
      Ride payments are processed via Stripe. Refunds are subject to the
      following rules:
    </p>
    <ul>
      <li>
        <strong>Ride cancelled by the driver before departure:</strong> full
        automatic refund within 5–10 business days to the original payment
        method.
      </li>
      <li>
        <strong>Ride cancelled by the passenger:</strong> eligibility for a
        refund depends on the notice period at the time of cancellation, as
        indicated in the app at the time of booking. Cancellations made with
        sufficient notice may be eligible for a full or partial refund.
      </li>
      <li>
        <strong>Ride not completed as expected:</strong>
        objectively verifiable cases, such as a driver no-show 30 minutes after
        scheduled departure, are processed automatically in the app. Other
        disagreements must be submitted through the in-app dispute feature
        within <strong>30 days</strong> of the ride.
      </li>
      <li>
        <strong>Charge dispute:</strong> use the in-app dispute feature or
        contact support. Disputes must be submitted within
        <strong>30 days</strong> of the transaction.
      </li>
    </ul>

    <h3>6.2 Premium Subscriptions</h3>
    <p>
      Premium subscriptions are purchased through the
      <strong>Apple App Store</strong> or <strong>Google Play Store</strong>.
      Subscription refunds are handled directly by Apple or Google:
    </p>
    <ul>
      <li>
        <strong>Apple App Store:</strong> request a refund at
        <a href="https://reportaproblem.apple.com" target="_blank"
          >reportaproblem.apple.com</a>.
      </li>
      <li>
        <strong>Google Play Store:</strong> request a refund via the Google
        Play app.
      </li>
    </ul>
    <p>
      We cannot issue refunds for in-app purchases on your behalf — all
      subscription billing and refunds are managed by Apple or Google. You may
      cancel your subscription at any time in your device's subscription
      settings; cancellation takes effect at the end of the current billing
      period.
    </p>

    <h2>7. Data Retention</h2>
    <table>
      <tr>
        <th>Data type</th>
        <th>Retention period</th>
      </tr>
      <tr>
        <td>Account and profile data</td>
        <td>Until account deletion</td>
      </tr>
      <tr>
        <td>Ride history</td>
        <td>
          Retained for audit and dispute resolution purposes, even after
          account deletion
        </td>
      </tr>
      <tr>
        <td>Payment transaction records</td>
        <td>
          <strong>10 years</strong> — statutory accounting retention period
        </td>
      </tr>
      <tr>
        <td>Chat messages</td>
        <td>Until deleted by the user or account deletion</td>
      </tr>
      <tr>
        <td>Images</td>
        <td>Until the associated message or account is deleted</td>
      </tr>
      <tr>
        <td>Analytics data</td>
        <td>
          Per Google Analytics retention settings (14 months by default)
        </td>
      </tr>
      <tr>
        <td>Crash reports</td>
        <td>90 days (Firebase Crashlytics default setting)</td>
      </tr>
      <tr>
        <td>Push notification tokens (FCM)</td>
        <td>Until logout or app uninstall</td>
      </tr>
      <tr>
        <td>Dispute and support documents</td>
        <td>5 years after case closure</td>
      </tr>
    </table>

    <h2>8. Your Rights</h2>
    <p>You have the following rights over your personal data:</p>
    <ul>
      <li>
        <strong>Access:</strong> obtain a copy of the personal data we hold
        about you
      </li>
      <li>
        <strong>Rectification:</strong> correct inaccurate or incomplete data
        (most fields are editable directly in the app)
      </li>
      <li>
        <strong>Deletion:</strong> delete your account and data via
        "Delete my account" in Settings, or via our
        <a href="https://sportaxitrip.com/delete-account.html"
          >online form</a>. See section 9 for details.
      </li>
      <li>
        <strong>Portability:</strong> receive your data in a structured,
        machine-readable format
      </li>
      <li>
        <strong>Restriction:</strong> request restriction of processing in
        certain circumstances
      </li>
      <li>
        <strong>Objection:</strong> object to the use of your data for
        analytics or service improvement
      </li>
      <li>
        <strong>Withdrawal of consent:</strong> withdraw consent for push
        notifications or analytics at any time in app Settings
      </li>
    </ul>
    <p>
      To exercise any of these rights, contact us at
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.
      We will respond within <strong>30 days</strong>.
    </p>

    <h2>9. Account Deletion</h2>
    <p>
      You can delete your account at any time via
      <strong>Settings → Account → Delete my account</strong> in the app, or
      via our
      <a href="https://sportaxitrip.com/delete-account.html"
        >web deletion form</a>.
    </p>

    <p><strong>Data deleted on account closure:</strong></p>
    <ul>
      <li>Profile, account information, profile photo, and cover image</li>
      <li>All rides created as a driver</li>
      <li>All bookings made as a passenger</li>
      <li>
        Your Google and/or Apple sign-in access is revoked, in addition to
        your SportConnect account being deleted
      </li>
      <li>
        Your Stripe customer profile (payment methods) is deleted. Your Stripe
        Connect driver account is closed once your balance is fully settled
        and no dispute is open; if a payout or dispute is pending, closure is
        completed once it resolves, consistent with payment-processor
        requirements
      </li>
      <li>All reviews written about other users</li>
      <li>All sent messages</li>
      <li>Vehicle information and associated documents</li>
      <li>Participation in all conversations, events, and notifications</li>
    </ul>
    <p><strong>Data retained after account closure:</strong></p>
    <ul>
      <li>
        Reviews written by other users about you, retained in anonymised form
        to preserve platform integrity
      </li>
      <li>
        Payment transaction records, retained for 10 years in compliance with
        statutory accounting requirements
      </li>
      <li>
        Ride records involving other participants, retained for potential
        dispute resolution
      </li>
    </ul>

    <p>
      <strong>Note:</strong> Account deletion is blocked if you have an active
      ride in progress. Complete or cancel the ride before requesting deletion.
    </p>

    <h2>10. Minors</h2>
    <p>
      SportConnect is not intended for persons under 18 years of age. You must
      confirm you are at least 18 when creating an account; this is a
      self-declaration and is not independently verified via an ID document or
      date of birth. If we discover that a user under 18 has created an
      account, we will delete it promptly. If you believe a minor has
      registered, contact us at
      <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.
    </p>

    <h2>11. Push Notifications</h2>
    <p>
      We send push notifications for ride updates, new messages, booking
      confirmations, and account activity. Your
      <strong>explicit consent</strong> is collected before any notification is
      sent. You can:
    </p>
    <ul>
      <li>
        Disable all notifications in Device Settings → Notifications →
        SportConnect
      </li>
      <li>
        Control individual notification types in the app under Settings →
        Notifications
      </li>
      <li>Set quiet hours to block notifications during certain time slots</li>
    </ul>

    <h2>12. Data Security</h2>
    <p>
      We implement the following security measures to protect your data:
    </p>
    <ul>
      <li>
        All communications between the app and our servers are encrypted via
        HTTPS/TLS
      </li>
      <li>
        Hashed password management and token-based sessions via Firebase
        Authentication
      </li>
      <li>
        Unauthorised API access protection via Firebase App Check
      </li>
      <li>
        Payment processing exclusively through Stripe, PCI DSS certified
      </li>
      <li>
        Firebase Storage access control limited to authorised users
      </li>
      <li>
        Re-authentication required for sensitive operations (payments, account
        deletion)
      </li>
      <li>Uploaded files are limited to 5–10 MB depending on the type of file</li>
    </ul>
    <p>
      No system is 100% secure. If you suspect unauthorised access to your
      account, change your password immediately and contact us.
    </p>

    <h2>13. Analytics Trackers</h2>
    <p>
      The SportConnect mobile app does not use cookies. Analytics and
      performance data are collected via Firebase SDKs (Google Analytics for
      Firebase and Firebase Crashlytics). This data is used solely to improve
      app reliability and experience, not for advertising purposes.
    </p>

    <h2>14. Changes to This Policy</h2>
    <p>
      We may update this Privacy Policy periodically. We will notify you of any
      significant changes via push notification or an in-app alert. The "Last
      updated" date at the top of this page always reflects the most recent
      version. Continued use of the app after a change constitutes acceptance
      of the updated policy.
    </p>

    <h2>15. Contact Us</h2>
    <p>
      For any questions about this Privacy Policy, to exercise your rights, or
      to report a privacy concern:
    </p>
    <ul>
      <li>
        Email:
        <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>
      </li>
      <li>
        Website:
        <a href="https://sportaxitrip.com" target="_blank">sportaxitrip.com</a>
      </li>
    </ul>

    <hr style="margin-top: 48px; border: none; border-top: 1px solid #e0e0e0" />
    <p style="color: #999; font-size: 0.85rem; text-align: center">
      © 2026 SportConnect. All rights reserved.
    </p>
  </body>
</html>
''';
}

class _LegalErrorView extends StatelessWidget {
  const _LegalErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              AdaptiveButton.child(
                onPressed: onRetry,
                child: Text(retryLabel),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
}
