// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../model/client.dart';
// import '../../services/client_service.dart';
// import '../../style/theme/colors.dart';

// class AccountsPage extends StatefulWidget {
//   const AccountsPage({super.key});

//   @override
//   State<AccountsPage> createState() => _AccountsPageState();
// }

// class _AccountsPageState extends State<AccountsPage>
//     with SingleTickerProviderStateMixin {
//   List<Client> _allClients = [];
//   List<Client> _filtered = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   late TabController _tabCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _tabCtrl = TabController(length: 3, vsync: this);
//     _tabCtrl.addListener(() => _applyFilters());
//     _loadClients();
//   }

//   @override
//   void dispose() {
//     _tabCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _loadClients() async {
//     setState(() => _isLoading = true);
//     final clients = await ClientService.fetchClients();
//     if (mounted) {
//       setState(() {
//         _allClients = clients;
//         _isLoading = false;
//         _applyFilters();
//       });
//     }
//   }

//   void _applyFilters() {
//     var list = List<Client>.from(_allClients);

//     // Filtre par onglet
//     switch (_tabCtrl.index) {
//       case 1: // Pro en attente
//         list = list.where((c) => c.isPro && !c.verified).toList();
//         break;
//       case 2: // Validés
//         list = list.where((c) => c.verified).toList();
//         break;
//     }

//     // Filtre texte
//     if (_searchQuery.isNotEmpty) {
//       final q = _searchQuery.toLowerCase();
//       list =
//           list.where((c) {
//             return c.fullName.toLowerCase().contains(q) ||
//                 c.email.toLowerCase().contains(q) ||
//                 c.telephone.contains(q);
//           }).toList();
//     }

//     setState(() => _filtered = list);
//   }

//   // Nombre de demandes pro en attente
//   int get _pendingCount =>
//       _allClients.where((c) => c.isPro && !c.verified).length;

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 768;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: isMobile ? _buildAppBar() : null,
//       body: Column(
//         children: [
//           if (!isMobile) _buildWebHeader(),
//           _buildTabs(),
//           Expanded(child: _buildContent()),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(kToolbarHeight),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: AppColors.appBarGradient,
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.shadowDeep,
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           automaticallyImplyLeading: false,
//           title: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Comptes',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 17,
//                 ),
//               ),
//               Text(
//                 '${_allClients.length} clients',
//                 style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
//               ),
//             ],
//           ),
//           centerTitle: true,
//           actions: [
//             if (_pendingCount > 0)
//               Padding(
//                 padding: const EdgeInsets.only(right: 14),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.9),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '$_pendingCount en attente',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWebHeader() {
//     return Container(
//       color: AppColors.surface,
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Comptes',
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${_allClients.length} clients · $_pendingCount en attente de validation',
//                 style: TextStyle(fontSize: 13, color: AppColors.textHint),
//               ),
//             ],
//           ),
//           const Spacer(),
//           // Barre de recherche
//           SizedBox(
//             width: 320,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadow,
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 onChanged: (v) {
//                   setState(() => _searchQuery = v);
//                   _applyFilters();
//                 },
//                 style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
//                 decoration: InputDecoration(
//                   hintText: 'Rechercher un client...',
//                   hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
//                   prefixIcon: const Icon(
//                     Icons.search_rounded,
//                     color: AppColors.accent,
//                     size: 20,
//                   ),
//                   filled: true,
//                   fillColor: Colors.transparent,
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 12,
//                     horizontal: 16,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabs() {
//     return Container(
//       color: AppColors.surface,
//       child: TabBar(
//         controller: _tabCtrl,
//         labelColor: AppColors.primary,
//         unselectedLabelColor: AppColors.textSecondary,
//         indicatorColor: AppColors.primary,
//         indicatorWeight: 3,
//         tabs: [
//           const Tab(text: 'Tous'),
//           Tab(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('En attente'),
//                 if (_pendingCount > 0) ...[
//                   const SizedBox(width: 6),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 7,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.orange,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       '$_pendingCount',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const Tab(text: 'Validés'),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (_isLoading) {
//       return Center(child: CircularProgressIndicator(color: AppColors.primary));
//     }

//     if (_filtered.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: AppColors.accentLight,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Icon(
//                 Icons.people_outline_rounded,
//                 size: 40,
//                 color: AppColors.accent,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _tabCtrl.index == 1
//                   ? 'Aucune demande en attente'
//                   : 'Aucun client',
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       color: AppColors.primary,
//       onRefresh: _loadClients,
//       child: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//         itemCount: _filtered.length,
//         itemBuilder:
//             (context, index) => _ClientCard(
//               client: _filtered[index],
//               index: index,
//               onVerified: () {
//                 setState(() {
//                   final i = _allClients.indexWhere(
//                     (c) => c.id == _filtered[index].id,
//                   );
//                   if (i != -1) {
//                     _allClients[i] = Client(
//                       id: _allClients[i].id,
//                       nom: _allClients[i].nom,
//                       prenom: _allClients[i].prenom,
//                       email: _allClients[i].email,
//                       telephone: _allClients[i].telephone,
//                       role: _allClients[i].role,
//                       justificatif: _allClients[i].justificatif,
//                       verified: true,
//                       createdAt: _allClients[i].createdAt,
//                     );
//                   }
//                   _applyFilters();
//                 });
//               },
//             ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // Carte Client
// // ─────────────────────────────────────────────
// class _ClientCard extends StatelessWidget {
//   const _ClientCard({
//     required this.client,
//     required this.index,
//     required this.onVerified,
//   });

//   final Client client;
//   final int index;
//   final VoidCallback onVerified;

//   @override
//   Widget build(BuildContext context) {
//     final isPro = client.isPro;
//     final isVerified = client.verified;
//     final needsAction = isPro && !isVerified;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(18),
//         border:
//             needsAction
//                 ? Border.all(color: Colors.orange.shade300, width: 1.5)
//                 : null,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Ligne principale ──
//             Row(
//               children: [
//                 // Avatar
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     gradient: AppColors.appBarGradient,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _initials(client.fullName),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 // Infos
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Flexible(
//                             child: Text(
//                               client.fullName,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color: AppColors.textPrimary,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           // Badge rôle
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 3,
//                             ),
//                             decoration: BoxDecoration(
//                               color:
//                                   isPro
//                                       ? AppColors.accentLight
//                                       : AppColors.primaryLight,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               isPro ? 'Professionnel' : 'Autre',
//                               style: TextStyle(
//                                 color:
//                                     isPro
//                                         ? AppColors.accent
//                                         : AppColors.primary,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         client.email,
//                         style: TextStyle(
//                           color: AppColors.textSecondary,
//                           fontSize: 12,
//                         ),
//                       ),
//                       Text(
//                         client.telephone,
//                         style: TextStyle(
//                           color: AppColors.textMuted,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Statut
//                 _buildStatusBadge(isVerified, isPro),
//               ],
//             ),

//             // ── Section pro : justificatif + bouton valider ──
//             if (isPro) ...[
//               const SizedBox(height: 12),
//               const Divider(height: 1),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   // Bouton voir justificatif
//                   if (client.justificatif.isNotEmpty)
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () async {
//                           final uri = Uri.parse(client.justificatif);
//                           if (await canLaunchUrl(uri)) {
//                             await launchUrl(
//                               uri,
//                               mode: LaunchMode.externalApplication,
//                             );
//                           }
//                         },
//                         icon: const Icon(Icons.description_outlined, size: 16),
//                         label: const Text('Voir justificatif'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: AppColors.accent,
//                           side: BorderSide(color: AppColors.accent),
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (client.justificatif.isNotEmpty && !isVerified)
//                     const SizedBox(width: 10),
//                   // Bouton valider
//                   if (!isVerified)
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _confirmValidate(context),
//                         icon: const Icon(Icons.check_circle_outline, size: 16),
//                         label: const Text('Valider le compte'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF059669),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusBadge(bool isVerified, bool isPro) {
//     if (isVerified) {
//       return Column(
//         children: [
//           Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 22),
//           const SizedBox(height: 2),
//           Text(
//             'Validé',
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF059669),
//             ),
//           ),
//         ],
//       );
//     }
//     if (isPro) {
//       return Column(
//         children: const [
//           Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 22),
//           SizedBox(height: 2),
//           Text(
//             'En attente',
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.w700,
//               color: Colors.orange,
//             ),
//           ),
//         ],
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Future<void> _confirmValidate(BuildContext context) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF059669).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.check_circle_outline,
//                     color: Color(0xFF059669),
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Valider le compte ?',
//                   style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
//                 ),
//               ],
//             ),
//             content: Text(
//               'Le compte de ${client.fullName} sera activé. Il pourra accéder à toutes les fonctionnalités professionnelles.',
//               style: const TextStyle(fontSize: 14),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Annuler'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF059669),
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Valider'),
//               ),
//             ],
//           ),
//     );

//     if (confirm == true) {
//       await ClientService.verifyClient(client.id);
//       onVerified();
//     }
//   }

//   String _initials(String name) {
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     return name.substring(0, 2).toUpperCase();
//   }
// }

import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../model/client.dart';
import '../../services/client_service.dart';
import '../../style/theme/colors.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage>
    with SingleTickerProviderStateMixin {
  List<Client> _allClients = [];
  List<Client> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => _applyFilters());
    _loadClients();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    final clients = await ClientService.fetchClients();
    if (mounted) {
      setState(() {
        _allClients = clients;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    var list = List<Client>.from(_allClients);
    switch (_tabCtrl.index) {
      case 1:
        list = list.where((c) => c.isPro && !c.verified).toList();
        break;
      case 2:
        list = list.where((c) => c.verified).toList();
        break;
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list =
          list.where((c) {
            return c.fullName.toLowerCase().contains(q) ||
                c.email.toLowerCase().contains(q) ||
                c.telephone.contains(q);
          }).toList();
    }
    setState(() => _filtered = list);
  }

  int get _pendingCount =>
      _allClients.where((c) => c.isPro && !c.verified).length;
  int get _verifiedCount => _allClients.where((c) => c.verified).length;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? _buildAppBar() : null,
      body: Column(
        children: [
          if (!isMobile) _buildWebHeader(),
          _buildTabs(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Comptes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Text(
                '${_allClients.length} clients',
                style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            if (_pendingCount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_pendingCount en attente',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ── Titre ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comptes clients',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez les accès et validez les professionnels',
                    style: TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
                ],
              ),
              const Spacer(),
              // ── Barre de recherche ──
              SizedBox(
                width: 300,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      _applyFilters();
                    },
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un client...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textHint,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  _applyFilters();
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Stat cards ──
          Row(
            children: [
              _buildStatCard(
                icon: Icons.people_alt_outlined,
                label: 'Total clients',
                value: '${_allClients.length}',
                color: AppColors.primary,
                bg: AppColors.primaryLight,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.hourglass_top_rounded,
                label: 'En attente',
                value: '$_pendingCount',
                color: Colors.orange.shade700,
                bg: Colors.orange.shade50,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.verified_rounded,
                label: 'Validés',
                value: '$_verifiedCount',
                color: const Color(0xFF059669),
                bg: const Color(0xFFECFDF5),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TabBar(
        controller: _tabCtrl,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          const Tab(text: 'Tous'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('En attente'),
                if (_pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Validés'),
                if (_verifiedCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_verifiedCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 44,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _tabCtrl.index == 1
                  ? 'Aucune demande en attente'
                  : 'Aucun client trouvé',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _tabCtrl.index == 1
                  ? 'Les nouvelles demandes professionnelles apparaîtront ici'
                  : 'Essayez de modifier votre recherche',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadClients,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _filtered.length,
        itemBuilder:
            (context, index) => _ClientCard(
              client: _filtered[index],
              index: index,
              onVerified: () {
                setState(() {
                  final i = _allClients.indexWhere(
                    (c) => c.id == _filtered[index].id,
                  );
                  if (i != -1) {
                    _allClients[i] = Client(
                      id: _allClients[i].id,
                      nom: _allClients[i].nom,
                      prenom: _allClients[i].prenom,
                      email: _allClients[i].email,
                      telephone: _allClients[i].telephone,
                      role: _allClients[i].role,
                      justificatif: _allClients[i].justificatif,
                      verified: true,
                      createdAt: _allClients[i].createdAt,
                    );
                  }
                  _applyFilters();
                });
              },
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Carte Client
// ─────────────────────────────────────────────
class _ClientCard extends StatefulWidget {
  const _ClientCard({
    required this.client,
    required this.index,
    required this.onVerified,
  });

  final Client client;
  final int index;
  final VoidCallback onVerified;

  @override
  State<_ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<_ClientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.index * 50),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.client;
    final isPro = c.isPro;
    final isVerified = c.verified;
    final needsAction = isPro && !isVerified;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border:
                needsAction
                    ? Border.all(color: Colors.orange.shade200, width: 1.5)
                    : isVerified
                    ? Border.all(
                      color: const Color(0xFF059669).withOpacity(0.2),
                      width: 1,
                    )
                    : null,
            boxShadow: [
              BoxShadow(
                color:
                    needsAction
                        ? Colors.orange.withOpacity(0.08)
                        : AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Ligne principale ──
                Row(
                  children: [
                    // Avatar avec initiales
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient:
                            needsAction
                                ? LinearGradient(
                                  colors: [
                                    Colors.orange.shade400,
                                    Colors.orange.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : AppColors.appBarGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (needsAction
                                    ? Colors.orange
                                    : AppColors.primary)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials(c.fullName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  c.fullName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildRoleBadge(isPro),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  c.email,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                c.telephone,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Statut
                    _buildStatusBadge(isVerified, isPro),
                  ],
                ),

                // ── Section pro ──
                if (isPro) ...[
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.shadow,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (c.justificatif != null && c.justificatif!.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final url =
                                  c.justificatif!.contains('.pdf')
                                      ? c.justificatif!.replaceFirst(
                                        'image/upload',
                                        'raw/upload',
                                      )
                                      : c.justificatif!;
                              html.window.open(url, '_blank');
                            },
                            icon: const Icon(
                              Icons.description_outlined,
                              size: 15,
                            ),
                            label: const Text(
                              'Justificatif',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: BorderSide(
                                color: AppColors.accent.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (c.justificatif != null &&
                          c.justificatif!.isNotEmpty &&
                          !isVerified)
                        const SizedBox(width: 10),
                      if (!isVerified)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmValidate(context),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 15,
                            ),
                            label: const Text(
                              'Valider',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      // Si déjà validé — message discret
                      if (isVerified)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF059669),
                                  size: 15,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Compte activé',
                                  style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(bool isPro) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPro ? AppColors.accentLight : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPro ? 'Pro' : 'Autre',
        style: TextStyle(
          color: isPro ? AppColors.accent : AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isVerified, bool isPro) {
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 13),
            SizedBox(width: 4),
            Text(
              'Validé',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),
      );
    }
    if (isPro) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_top_rounded,
              color: Colors.orange.shade700,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              'En attente',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _confirmValidate(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Valider le compte ?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le compte professionnel de ${widget.client.fullName} sera activé.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF059669),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Il pourra accéder aux tarifs et fonctionnalités professionnelles.',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text(
                  'Valider',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ClientService.verifyClient(widget.client.id);
      widget.onVerified();
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}
