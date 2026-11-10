# esme2026

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# esme2026

## Persistance locale (utilisateur et theme)

Les donnees sont enregistrees sur l'appareil avec `shared_preferences`,
chargees une fois au demarrage dans `main.dart`.

- Utilisateur : a la fin de l'onboarding, `OnboardingController` enregistre un
  [`CurrentUser`](lib/domain/models/current_user.dart) (role, nom, metier,
  centres d'interet, localisation) via
  [`CurrentUserRepository`](lib/domain/repositories/current_user_repository.dart).
  Au lancement suivant, le routeur ouvre directement l'accueil. Le menu
  « Reglages » de l'accueil permet de recommencer l'inscription.
- Theme : clair, sombre ou comme l'appareil, choisi depuis le menu « Reglages »
  de l'accueil et enregistre via
  [`SettingsRepository`](lib/domain/repositories/settings_repository.dart).

L'avancement d'un onboarding non termine n'est pas enregistre : un redemarrage
en cours de parcours le recommence. Sans repository fourni (tests), l'application
utilise des versions en memoire et ne conserve rien. Le stockage n'est pas
chiffre : n'y mettre aucune donnee sensible.

## Onboarding

L'application ouvre l'onboarding au premier lancement ; l'authentification
n'est pas encore branchee.

- Artisan : choix du profil -> metier -> localisation -> KYC -> accueil.
- Particulier : choix du profil -> centres d'interet artisanaux -> prenom et nom
  -> localisation -> accueil.

La machine a etats Dart pure est dans
[`onboarding_flow.dart`](lib/domain/onboarding/onboarding_flow.dart).
[`OnboardingController`](lib/application/onboarding_controller.dart) pilote cette
machine, les saisies, le retour arriere et le KYC asynchrone, hors de l'UI.
La page gere uniquement le cycle de vie du controleur et observe ses notifications.
Les widgets `OnboardingView` et `OnboardingStepView` affichent l'etat et transmettent
les actions, sans decider des transitions ni appeler les repositories.
Chaque ecran possede son propre widget dans
[`ui/widgets/onboarding`](lib/ui/widgets/onboarding/). Les saisies sont conservees
en memoire lors d'un retour arriere ; changer de profil efface les saisies
specifiques a l'ancien profil.

Le contrat [`KycRepository`](lib/domain/repositories/kyc_repository.dart) est
injectable. Comme les autres repositories, la facade
[`KycRepository.instance`](lib/data/repositories/kyc_repository.dart) expose le
singleton [`KycRepositoryImpl`](lib/data/repositories/kyc_repository_impl.dart).
L'onboarding utilise ce singleton par defaut. Cette implementation mockee
simule une approbation asynchrone, sans document, appel reseau ni verification
reelle. L'interface signale explicitement cette simulation ; refus et erreurs
`KycException` permettent de reessayer. Ce resultat ne confere aucun statut
verifie au compte ou au profil artisan.

## Modeles metier : particuliers et artisans

Les classes sont dans [`lib/domain/models/`](lib/domain/models/).
Import global disponible :

```dart
import 'package:esme26/domain/models/models.dart';
```

### Clean Architecture

- `domain/models` : entites et objets-valeurs Dart purs, sans Flutter, JSON,
  Firebase ni dependance vers `data` ou `ui`.
- `data/models` : les anciens imports de `User` et `Adress` restent disponibles
  par reexport, sans dupliquer les classes. Les futurs DTO et conversions
  JSON/API/base de donnees doivent vivre dans cette couche, pas dans le domaine.
- Les contrats de repositories sont dans `domain/repositories` ; leurs
  implementations mockees et points d'acces singleton sont dans
  `data/repositories`. Les cas d'utilisation dependent uniquement des contrats
  du domaine.

### Catalogue

| Fichier | Modeles et usage |
| --- | --- |
| `user.dart`, `customer_profile.dart` | Compte, roles particulier/artisan cumulables, profil particulier |
| `artisan_profile.dart` | Entreprise, immatriculation, metiers, tarifs et zones d'intervention (`ServiceArea`) |
| `adress.dart`, `geo_point.dart` | Adresse et coordonnees ; orthographe `Adress` conservee pour compatibilite |
| `trade.dart` | Catalogue hierarchique de metiers et specialites |
| `professional_document.dart` | Immatriculation, qualifications, assurances et verification |
| `portfolio_project.dart` | Realisations de l'artisan et medias |
| `attachment.dart` | Metadonnees des photos, videos et documents |
| `work_request.dart` | Demande de travaux, lieu, budget, urgence et periode souhaitee |
| `quote.dart` | Devis, lignes (`QuoteLine`), quantites, unites et TVA |
| `job.dart` | Chantier issu d'un devis accepte, montant convenu et planification |
| `appointment.dart`, `availability.dart` | Rendez-vous de visite et plages de disponibilite |
| `conversation.dart`, `message.dart` | Discussion particulier/artisan, messages et pieces jointes |
| `review.dart` | Avis lie a un chantier, note de 1 a 5 et reponse de l'artisan |
| `invoice.dart` | Facture et lignes tarifaires figees |
| `payment.dart` | Paiement, acompte/solde et remboursements (`Refund`) |
| `dispute.dart` | Litige de chantier et justificatifs |
| `favorite.dart`, `app_notification.dart` | Artisans favoris et notifications |
| `money.dart`, `time_slot.dart` | Montant (`Money`), fourchette de budget (`Budget`) et periode |

### Relations et regles

- Les relations utilisent des identifiants, sans graphe d'objets cyclique :
  `User` -> profils ; `WorkRequest` -> `Quote` -> `Job` -> `Invoice` ->
  `Payment` -> `Refund`. `artisanId` et `customerId` designent des `User.id`.
  `ProfessionalDocument`, `PortfolioProject` et `Availability` sont rattaches
  a l'artisan ; `Message` a une `Conversation`.
- Les identifiants sont attribues par les futurs services/repositories.
  Seul `User.id` est nullable pour conserver l'inscription existante avant
  persistance. Les dates ne sont pas generees implicitement ; utiliser UTC aux
  frontieres de persistance. Le champ historique de naissance reste en
  millisecondes depuis l'epoch.
- Champs `final`, listes et ensembles copies et non modifiables.
  Les erreurs locales (montant negatif, devis vide, devis multidevise,
  periode inversee, coordonnees invalides, message vide, etc.) provoquent
  une `ArgumentError`, y compris en production.
- `Money.minorUnits` utilise des entiers (centimes pour EUR), jamais un prix
  en `double`. Une quantite de ligne peut etre fractionnaire. Le sous-total
  est arrondi au centime par ligne ; la TVA en points de base
  (`2000` = 20 %) est arrondie par ligne au plus proche, demi vers le haut.
  Les devis et factures reutilisent les memes lignes pour les calculs HT/TVA/TTC.
  Le code devise est valide syntaxiquement, sans catalogue ISO embarque.
- Les objets ne prouvent pas l'autorisation ni l'existence des relations.
  Les cas d'utilisation/backend devront controler les roles, transitions
  de statut, chevauchements de disponibilites, devis accepte, unicite d'avis
  par chantier termine, montants de paiements/remboursements et validite
  des assurances. Les modeles n'effectuent aucun paiement reel.
- Les etats financiers sont mis a jour par le backend/prestataire de paiement,
  jamais consideres comme fiables sur la seule declaration du client.
  Seules les references du prestataire sont conservees : aucune donnee de carte.
  Les droits d'acces aux adresses, documents et medias doivent etre controles
  par le backend ; aucune URL publique n'est imposee.

Validation ciblee :

```bash
dart analyze lib/domain/models lib/data/models test/domain/models
flutter test test/domain/models
```

## Repositories et donnees mockees

Chaque entite du catalogue dispose d'un contrat dans
[`lib/domain/repositories/`](lib/domain/repositories/), d'un point d'acces
`XRepository.instance` et d'une implementation `XRepositoryImpl` dans
[`lib/data/repositories/`](lib/data/repositories/).
Le contrat commun `Repository<T, K>` propose des operations synchrones :

- `getAll()` : instantane non modifiable de la collection ;
- `getById(id)` : entite ou `null` si absente ;
- `save(entity)` : ajout ou remplacement par cle, avec identifiant non vide
  obligatoire (pas de generation implicite) ;
- `delete(id)` : suppression, ou `StateError` si la cle est absente.

```dart
import 'package:esme26/data/repositories/repositories.dart';

final repository = WorkRequestRepository.instance;
final requests = repository.getAll();
final request = repository.getById('request-1');
if (request != null) {
  repository.save(request);
}

final favorites = FavoriteRepository.instance;
final favorite = favorites.getById((
  customerId: 'customer-1',
  artisanId: 'artisan-1',
));
```

Les profils sont indexes par `userId`. Les favoris utilisent une cle composee
`FavoriteId` (record nomme `customerId`/`artisanId`), sans concatenation de chaines.
Les autres entites utilisent leur `id`.

### Singletons et injection

Les implementations suivent le pattern existant : champ statique prive
`_instance`, constructeur prive `_internal`, constructeur `factory` renvoyant
toujours la meme instance. L'acces par interface et par implementation partage
donc le meme etat :

```dart
import 'package:esme26/data/repositories/trade_repository.dart';
import 'package:esme26/data/repositories/trade_repository_impl.dart';

final sameInstance = identical(
  TradeRepository.instance,
  TradeRepositoryImpl(),
); // true
```

Le domaine n'importe jamais ces singletons : les petits points d'acces dans
`data/repositories` implementent les contrats du domaine et choisissent les
implementations, afin de conserver `XRepository.instance` sans dependance
`domain -> data`. Dans un cas d'utilisation, injecter le contrat du domaine :

```dart
import 'package:esme26/domain/repositories/work_request_repository.dart';

class ListWorkRequests {
  final WorkRequestRepository repository;
  ListWorkRequests(this.repository);
}
```

`UserRepository.instance` conserve l'implementation selectionnee
`UserRepositoryJP`, qui est maintenant elle aussi un vrai singleton.
`UserRepositoryImpl()` reste disponible comme singleton alternatif, avec son
propre stockage. `getUser()` et `setUser()` sont conserves pour l'inscription.
Un utilisateur sans `id` peut etre selectionne comme brouillon mais n'est pas
ajoute au catalogue ; avec un `id`, `setUser` l'enregistre aussi. Modifier le
compte courant via `save` actualise la session ; le supprimer la vide.

### Contenu et limites des mocks

[`lib/data/mocks/mock_data.dart`](lib/data/mocks/mock_data.dart) contient des
donnees fictives et deterministes : particulier, artisan, metiers, medias,
assurance, realisation, deux demandes/devis/chantiers, rendez-vous,
disponibilites, conversation/messages, avis, factures/paiements, remboursement,
litige, favoris et notifications. Les identifiants, montants et relations
sont coherents au chargement ; les dates sont fixes et en UTC. Les URL en
`example.test` sont des placeholders, pas des fichiers accessibles.

`Adress`, `GeoPoint`, `Money`, `Budget`, `TimeSlot`, `ServiceArea` et `QuoteLine`
sont des objets-valeurs inclus dans les entites mockees. Ils n'ont pas de
repository independant, car ils n'ont pas d'identite autonome.

Le stockage est en memoire dans l'isolate courant : il est partage entre les
acces au meme singleton, mais perdu au redemarrage. Aucun appel reseau,
persistance disque, paiement reel, controle d'autorisation, cascade de
suppression, transaction ni validation des relations entre repositories
n'est simule. Les regles metier restent a implementer dans les cas
d'utilisation/backend.

Les implementations exposent `reset()` pour restaurer leurs fixtures pendant
les tests/demonstrations, sans changer l'instance singleton. Cette methode ne
fait pas partie des contrats du domaine et ne reinitialise pas les autres
repositories.

Validation ciblee des repositories et de la compatibilite existante :

```bash
dart analyze lib/domain/repositories lib/data/repositories lib/data/mocks test/data/repositories test/domain/models
flutter test test/data/repositories test/domain/models
```

class 2027 de appli
