import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/donations/data/donation_repository.dart';
import '../../features/needs/data/need_repository.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../../features/organizations/data/organization_repository.dart';
import '../../features/profile/data/user_repository.dart';
import '../../features/settings/data/support_repository.dart';
import '../../features/sponsorships/data/sponsorship_repository.dart';
import '../../features/volunteering/data/application_repository.dart';
import '../../features/volunteering/data/volunteer_repository.dart';
import '../auth/project_auth_accounts.dart';
import '../models/application_model.dart';
import '../models/child_sponsorship_model.dart';
import '../models/donation_model.dart';
import '../models/need_model.dart';
import '../models/notification_model.dart';
import '../models/opportunity_model.dart';
import '../models/organization_model.dart';
import '../models/post_model.dart';
import '../models/subscription_model.dart';
import '../models/support_ticket_model.dart';
import '../models/user_model.dart';

const _adminUid = ProjectAuthAccounts.adminUid;
const _orgManagerUid = ProjectAuthAccounts.orgManagerUid;
const _volunteerRahimUid = ProjectAuthAccounts.volunteerRahimUid;
const _donorSaymumUid = ProjectAuthAccounts.donorSaymumUid;
const _opportunityPosterUid = ProjectAuthAccounts.opportunityPosterUid;
const _donorSadiaUid = ProjectAuthAccounts.donorSadiaUid;
const _donorFahimUid = ProjectAuthAccounts.donorFahimUid;
const _donorNabilaUid = ProjectAuthAccounts.donorNabilaUid;
const _volunteerRituUid = ProjectAuthAccounts.volunteerRituUid;

const _adminEmail = ProjectAuthAccounts.adminEmail;
const _orgManagerEmail = ProjectAuthAccounts.orgManagerEmail;
const _volunteerRahimEmail = ProjectAuthAccounts.volunteerRahimEmail;
const _donorSaymumEmail = ProjectAuthAccounts.donorSaymumEmail;
const _opportunityPosterEmail = ProjectAuthAccounts.opportunityPosterEmail;
const _donorSadiaEmail = ProjectAuthAccounts.donorSadiaEmail;
const _donorFahimEmail = ProjectAuthAccounts.donorFahimEmail;
const _donorNabilaEmail = ProjectAuthAccounts.donorNabilaEmail;
const _volunteerRituEmail = ProjectAuthAccounts.volunteerRituEmail;

class DatabaseInitializer {
  final OrganizationRepository orgRepo;
  final UserRepository userRepo;
  final NeedRepository needRepo;
  final VolunteerRepository volunteerRepo;
  final DonationRepository donationRepo;
  final ApplicationRepository applicationRepo;
  final NotificationRepository notificationRepo;
  final SponsorshipRepository sponsorshipRepo;
  final SupportRepository supportRepo;
  final FirebaseFirestore _firestore;

  DatabaseInitializer({
    required this.orgRepo,
    required this.userRepo,
    required this.needRepo,
    required this.volunteerRepo,
    required this.donationRepo,
    required this.applicationRepo,
    required this.notificationRepo,
    required this.sponsorshipRepo,
    required this.supportRepo,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<void> initializeProductionData() async {
    final users = _buildUsers();
    final organizations = _buildOrganizations();
    final needs = _buildNeeds();
    final volunteerOpportunities = _buildVolunteerOpportunities();
    final lifeOpportunities = _buildLifeOpportunities();
    final children = _buildChildSponsorships();
    final subscriptions = _buildSubscriptions();
    final donations = _buildDonations();
    final posts = _buildPosts();
    final applications = _buildApplications();
    final notifications = _buildNotifications();
    final tickets = _buildSupportTickets();
    final activityLogs = _buildActivityLogs();
    final historyRecords = _buildHistoryRecords();

    for (final user in users) {
      await userRepo.saveUserProfile(user);
      await userRepo.setUserPhoneMapping(user.phone, user.email);
    }

    for (final organization in organizations) {
      await orgRepo.saveOrganization(organization);
    }

    for (final need in needs) {
      await needRepo.saveNeed(need);
    }

    for (final opportunity in volunteerOpportunities) {
      await volunteerRepo.saveOpportunity(opportunity);
    }

    for (final opportunity in lifeOpportunities) {
      await volunteerRepo.saveLifeOpportunity(opportunity);
    }

    for (final child in children) {
      await sponsorshipRepo.saveChildSponsorship(child);
    }

    for (final subscription in subscriptions) {
      await sponsorshipRepo.saveSubscription(subscription);
    }

    for (final donation in donations) {
      await donationRepo.saveDonation(donation);
    }

    for (final post in posts) {
      await _firestore.collection('posts').doc(post.id).set(
            post.toMap(),
            SetOptions(merge: true),
          );
    }

    for (final application in applications) {
      await applicationRepo.submitApplication(application);
    }

    for (final notification in notifications) {
      await notificationRepo.sendNotification(notification);
    }

    for (final ticket in tickets) {
      await supportRepo.updateTicket(ticket);
    }

    for (final log in activityLogs) {
      await _firestore.collection('activity_logs').doc(log['id'] as String).set(
            log,
            SetOptions(merge: true),
          );
    }

    for (final record in historyRecords) {
      await _firestore.collection('history_records').doc(record['id'] as String).set(
            record,
            SetOptions(merge: true),
          );
    }

    await _firestore.collection('platform_metadata').doc('seed_status').set(
      {
        'label': 'TinyWings 2.0 finalization dataset',
        'lastSeededAt': DateTime.now().toIso8601String(),
        'users': users.length,
        'organizations': organizations.length,
        'needs': needs.length,
        'donations': donations.length,
        'posts': posts.length,
      },
      SetOptions(merge: true),
    );
  }

  List<UserModel> _buildUsers() {
    return [
      UserModel(
        uid: _adminUid,
        email: _adminEmail,
        name: 'Farzana Rahman',
        phone: '+8801711123401',
        district: 'Dhaka',
        address: 'House 17, Road 8, Banani DOHS, Dhaka',
        gender: 'Female',
        dob: '1990-02-14',
        bio: 'Founder administrator overseeing nationwide partnerships, approvals, and impact reporting.',
        role: UserRole.admin,
        status: 'active',
        profession: 'Platform Director',
        skills: 'Operations, compliance, field coordination',
        emergencyPhone: '+8801911123401',
        bloodGroup: 'B+',
        type: 'staff',
        createdAt: _daysAgo(420),
      ),
      UserModel(
        uid: _orgManagerUid,
        email: _orgManagerEmail,
        name: 'Mahmudul Hasan',
        phone: '+8801812234502',
        district: 'Dhaka',
        address: 'Shapla Child Development Home, Kadamtali, Dhaka',
        gender: 'Male',
        dob: '1987-08-11',
        bio: 'Resident manager coordinating child sponsorship, nutrition, and family reintegration services.',
        role: UserRole.orphanageAdmin,
        status: 'active',
        assignedOrphanageId: 'org_shapla_home',
        profession: 'Shelter Manager',
        skills: 'Case management, logistics, donor coordination',
        emergencyPhone: '+8801912234502',
        bloodGroup: 'O+',
        organizationId: 'org_shapla_home',
        organizationName: 'Shapla Child Development Home',
        type: 'staff',
        createdAt: _daysAgo(365),
      ),
      UserModel(
        uid: _volunteerRahimUid,
        email: _volunteerRahimEmail,
        name: 'Md. Rahim Uddin',
        phone: '+8801713345603',
        district: 'Chattogram',
        address: 'Nasirabad Housing Society, Chattogram',
        gender: 'Male',
        dob: '1998-11-03',
        bio: 'Youth volunteer focused on logistics, field events, and mentoring sessions.',
        role: UserRole.volunteer,
        status: 'active',
        profession: 'Supply Chain Executive',
        skills: 'Event operations, mentoring, documentation',
        emergencyPhone: '+8801913345603',
        bloodGroup: 'A+',
        volunteerMetadata: {
          'availability': 'Weekends',
          'preferredDistricts': ['Dhaka', 'Chattogram'],
        },
        type: 'volunteer',
        createdAt: _daysAgo(240),
      ),
      UserModel(
        uid: _donorSaymumUid,
        email: _donorSaymumEmail,
        name: 'Saymum Rahman',
        phone: '+8801714456704',
        district: 'Dhaka',
        address: 'Bashundhara R/A, Dhaka',
        gender: 'Female',
        dob: '1996-05-18',
        bio: 'Recurring donor supporting education, emergency relief, and girls’ wellbeing programmes.',
        role: UserRole.donor,
        status: 'active',
        profession: 'Senior Product Designer',
        skills: 'Community fundraising, storytelling',
        emergencyPhone: '+8801914456704',
        bloodGroup: 'AB+',
        type: 'donor',
        createdAt: _daysAgo(310),
      ),
      UserModel(
        uid: _opportunityPosterUid,
        email: _opportunityPosterEmail,
        name: 'Nafisa Karim',
        phone: '+8801715567805',
        district: 'Chattogram',
        address: 'Lighthouse Skills Center, Halishahar, Chattogram',
        gender: 'Female',
        dob: '1993-09-25',
        bio: 'Programme officer publishing scholarships, training circulars, and career referrals.',
        role: UserRole.opportunityPoster,
        status: 'active',
        profession: 'Programme Officer',
        skills: 'Career counselling, employer liaison',
        emergencyPhone: '+8801915567805',
        bloodGroup: 'B-',
        organizationId: 'org_light_house',
        organizationName: 'Lighthouse Skills Center',
        type: 'staff',
        createdAt: _daysAgo(290),
      ),
      UserModel(
        uid: _donorSadiaUid,
        email: _donorSadiaEmail,
        name: 'Sadia Anjum',
        phone: '+8801716678906',
        district: 'Rajshahi',
        address: 'Upashahar, Rajshahi',
        gender: 'Female',
        dob: '1992-03-07',
        bio: 'Monthly sponsor championing long-term child education support.',
        role: UserRole.donor,
        status: 'active',
        profession: 'Bank Officer',
        skills: 'Mentoring, budgeting',
        emergencyPhone: '+8801916678906',
        bloodGroup: 'O-',
        type: 'donor',
        createdAt: _daysAgo(270),
      ),
      UserModel(
        uid: _donorFahimUid,
        email: _donorFahimEmail,
        name: 'Fahim Chowdhury',
        phone: '+8801717789007',
        district: 'Sylhet',
        address: 'Subid Bazar, Sylhet',
        gender: 'Male',
        dob: '1989-12-19',
        bio: 'Corporate donor funding learning materials and nutrition support.',
        role: UserRole.donor,
        status: 'active',
        profession: 'Business Development Lead',
        skills: 'Corporate partnerships',
        emergencyPhone: '+8801917789007',
        bloodGroup: 'A-',
        type: 'institution',
        createdAt: _daysAgo(215),
      ),
      UserModel(
        uid: _donorNabilaUid,
        email: _donorNabilaEmail,
        name: 'Nabila Haque',
        phone: '+8801718890108',
        district: 'Khulna',
        address: 'Sonadanga, Khulna',
        gender: 'Female',
        dob: '1995-07-30',
        bio: 'Long-time supporter focused on medicine access and nutrition recovery.',
        role: UserRole.donor,
        status: 'active',
        profession: 'Medical Officer',
        skills: 'Health outreach',
        emergencyPhone: '+8801918890108',
        bloodGroup: 'B+',
        type: 'donor',
        createdAt: _daysAgo(180),
      ),
      UserModel(
        uid: _volunteerRituUid,
        email: _volunteerRituEmail,
        name: 'Ritu Akter',
        phone: '+8801719901209',
        district: 'Barishal',
        address: 'Rupatoli, Barishal',
        gender: 'Female',
        dob: '1999-01-21',
        bio: 'Volunteer mentor supporting adolescent girls, reading circles, and field reporting.',
        role: UserRole.volunteer,
        status: 'active',
        profession: 'Teaching Assistant',
        skills: 'Child mentoring, reporting, logistics',
        emergencyPhone: '+8801919901209',
        bloodGroup: 'O+',
        volunteerMetadata: {
          'availability': 'Friday and Saturday',
          'preferredDistricts': ['Barishal', 'Dhaka'],
        },
        type: 'volunteer',
        createdAt: _daysAgo(150),
      ),
    ];
  }

  List<Organization> _buildOrganizations() {
    return [
      _organization(
        id: 'org_shapla_home',
        name: 'Shapla Child Development Home',
        location: 'Kadamtali, Dhaka',
        phone: '+88029633121',
        email: 'care@shaplahome.org',
        imageUrl:
            'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=1200&q=80',
        description:
            'Integrated shelter and education programme serving children in high-risk urban communities.',
        about:
            'Shapla Child Development Home runs residential care, school readiness, nutrition follow-up, and family tracing support for children from Dhaka and surrounding districts.',
        totalChildren: 94,
        impactChildCount: 41,
        isFeatured: true,
      ),
      _organization(
        id: 'org_jaago_learning',
        name: 'JAAGO Learning Hub Rayerbazar',
        location: 'Rayerbazar, Dhaka',
        phone: '+880255031551',
        email: 'rayerbazar@jaago.org',
        imageUrl:
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=1200&q=80',
        description:
            'Community school and digital access hub for children from low-income families.',
        about:
            'The learning hub combines classroom support, digital literacy, and parent engagement to keep children in school and connected to opportunity.',
        totalChildren: 138,
        impactChildCount: 53,
        isFeatured: true,
      ),
      _organization(
        id: 'org_brahmaputra_trust',
        name: 'Brahmaputra Family Support Trust',
        location: 'Ulipur, Kurigram',
        phone: '+88058164452',
        email: 'operations@brahmaputratrust.bd',
        imageUrl:
            'https://images.unsplash.com/photo-1529390079861-591de354faf5?auto=format&fit=crop&w=1200&q=80',
        description:
            'Flood-prone community support programme focused on food security, education continuity, and child protection.',
        about:
            'The trust supports riverbank-displaced families with school kits, case management, and emergency nutrition assistance during seasonal flooding.',
        totalChildren: 82,
        impactChildCount: 29,
        isFeatured: false,
      ),
      _organization(
        id: 'org_light_house',
        name: 'Lighthouse Skills Center',
        location: 'Halishahar, Chattogram',
        phone: '+880312773118',
        email: 'skills@lighthouse.org.bd',
        imageUrl:
            'https://images.unsplash.com/photo-1491841573634-28140fc7ced7?auto=format&fit=crop&w=1200&q=80',
        description:
            'Youth transition centre connecting older adolescents to training, jobs, and safe housing.',
        about:
            'Lighthouse supports children and young adults aging out of institutional care with employability training, internships, and psychosocial support.',
        totalChildren: 67,
        impactChildCount: 18,
        isFeatured: true,
      ),
      _organization(
        id: 'org_padma_shelter',
        name: 'Padma Shelter & School',
        location: 'Boalia, Rajshahi',
        phone: '+880721118301',
        email: 'hello@padmashelter.org',
        imageUrl:
            'https://images.unsplash.com/photo-1509099836639-18ba1795216d?auto=format&fit=crop&w=1200&q=80',
        description:
            'Safe shelter, school support, and nutrition programme for girls and boys at risk.',
        about:
            'Padma Shelter combines a transitional home with tutoring, health referrals, and family strengthening support for children from Rajshahi division.',
        totalChildren: 76,
        impactChildCount: 24,
        isFeatured: false,
      ),
      _organization(
        id: 'org_sundarban_care',
        name: 'Sundarban Care Initiative',
        location: 'Koyra, Khulna',
        phone: '+880477551490',
        email: 'field@sundarbancare.org',
        imageUrl:
            'https://images.unsplash.com/photo-1489345745021-15c3d2a4d28f?auto=format&fit=crop&w=1200&q=80',
        description:
            'Cyclone-resilient child support programme focused on health, water access, and school continuity.',
        about:
            'The initiative serves children in coastal communities affected by salinity, storms, and school disruption, with targeted support for girls and single-parent households.',
        totalChildren: 59,
        impactChildCount: 17,
        isFeatured: false,
      ),
      _organization(
        id: 'org_coastal_resilience',
        name: 'Coastal Resilience Family Centre',
        location: 'Ukhiya, Cox’s Bazar',
        phone: '+880342722617',
        email: 'team@coastalresilience.org',
        imageUrl:
            'https://images.unsplash.com/photo-1469571486292-b53601010b89?auto=format&fit=crop&w=1200&q=80',
        description:
            'Child wellbeing programme serving displaced and highly vulnerable families.',
        about:
            'The centre runs nutrition screening, dignity support, and safe learning activities with a strong focus on continuity and dignity for children in crisis settings.',
        totalChildren: 121,
        impactChildCount: 47,
        isFeatured: true,
      ),
      _organization(
        id: 'org_nilphamari_care',
        name: 'Nilphamari Care House',
        location: 'Saidpur, Nilphamari',
        phone: '+880553022190',
        email: 'support@nilphamaricare.org',
        imageUrl:
            'https://images.unsplash.com/photo-1542810634-71271d05dcfe?auto=format&fit=crop&w=1200&q=80',
        description:
            'Residential and family support home serving children in northern Bangladesh.',
        about:
            'Nilphamari Care House provides schooling, nutrition, and case support to children from low-income and disaster-affected families across the north.',
        totalChildren: 71,
        impactChildCount: 23,
        isFeatured: false,
      ),
      _organization(
        id: 'org_smile_sylhet',
        name: 'Smile Sylhet Education Home',
        location: 'Shibgonj, Sylhet',
        phone: '+880821772144',
        email: 'info@smilesylhet.org',
        imageUrl:
            'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=1200&q=80',
        description:
            'Education-first programme with school sponsorship, boarding support, and mentorship.',
        about:
            'Smile Sylhet keeps children in school through hostel support, tutoring, and leadership mentoring for adolescents.',
        totalChildren: 88,
        impactChildCount: 31,
        isFeatured: false,
      ),
      _organization(
        id: 'org_safe_steps',
        name: 'Safe Steps Barishal Home',
        location: 'Rupatoli, Barishal',
        phone: '+880431773509',
        email: 'care@safestepsbarishal.org',
        imageUrl:
            'https://images.unsplash.com/photo-1531206715517-5c2c5f6b0d27?auto=format&fit=crop&w=1200&q=80',
        description:
            'Nutrition and shelter support with strong adolescent life-skills programming.',
        about:
            'Safe Steps offers a structured care environment, daily tutoring, and life-skills coaching for children and teens navigating social and economic vulnerability.',
        totalChildren: 64,
        impactChildCount: 19,
        isFeatured: false,
      ),
    ];
  }

  List<Need> _buildNeeds() {
    return [
      _need(
        id: 'need_shapla_breakfast',
        organizationId: 'org_shapla_home',
        organizationName: 'Shapla Child Development Home',
        title: 'Breakfast Nutrition Packs',
        subtitle: 'Milk, eggs, bananas, and lentils for the next 6 weeks.',
        category: 'Food',
        priority: 'Urgent',
        targetQuantity: 180,
        fulfilledQuantity: 126,
        unit: 'packs',
        deadline: 'May 15, 2026',
        createdAt: _daysAgo(18),
      ),
      _need(
        id: 'need_shapla_schoolbags',
        organizationId: 'org_shapla_home',
        organizationName: 'Shapla Child Development Home',
        title: 'School Bags and Stationery',
        subtitle: 'Backpacks, geometry boxes, and exercise books for new admissions.',
        category: 'Education',
        priority: 'Normal',
        targetQuantity: 40,
        fulfilledQuantity: 18,
        unit: 'sets',
        deadline: 'May 28, 2026',
        createdAt: _daysAgo(11),
      ),
      _need(
        id: 'need_jaago_tablets',
        organizationId: 'org_jaago_learning',
        organizationName: 'JAAGO Learning Hub Rayerbazar',
        title: 'Refurbished Learning Tablets',
        subtitle: 'Devices for digital classes and homework follow-up.',
        category: 'Education',
        priority: 'Urgent',
        targetQuantity: 24,
        fulfilledQuantity: 14,
        unit: 'units',
        deadline: 'May 20, 2026',
        createdAt: _daysAgo(22),
      ),
      _need(
        id: 'need_jaago_medical',
        organizationId: 'org_jaago_learning',
        organizationName: 'JAAGO Learning Hub Rayerbazar',
        title: 'First Aid and Fever Care Stock',
        subtitle: 'Thermometers, saline, antiseptic, and basic medicine for school clinic use.',
        category: 'Medicine',
        priority: 'Normal',
        targetQuantity: 30,
        fulfilledQuantity: 12,
        unit: 'kits',
        deadline: 'June 2, 2026',
        createdAt: _daysAgo(7),
      ),
      _need(
        id: 'need_brahmaputra_dry_food',
        organizationId: 'org_brahmaputra_trust',
        organizationName: 'Brahmaputra Family Support Trust',
        title: 'Dry Food Hampers for Riverbank Families',
        subtitle: 'Rice, lentils, oil, oral saline, and infant cereal.',
        category: 'Food',
        priority: 'Urgent',
        targetQuantity: 220,
        fulfilledQuantity: 154,
        unit: 'packs',
        deadline: 'May 10, 2026',
        createdAt: _daysAgo(15),
      ),
      _need(
        id: 'need_brahmaputra_raincoats',
        organizationId: 'org_brahmaputra_trust',
        organizationName: 'Brahmaputra Family Support Trust',
        title: 'Raincoats and Waterproof Sandals',
        subtitle: 'Protective gear for children commuting to school during monsoon.',
        category: 'Clothing',
        priority: 'Normal',
        targetQuantity: 90,
        fulfilledQuantity: 31,
        unit: 'sets',
        deadline: 'June 14, 2026',
        createdAt: _daysAgo(6),
      ),
      _need(
        id: 'need_lighthouse_laptops',
        organizationId: 'org_light_house',
        organizationName: 'Lighthouse Skills Center',
        title: 'Shared Training Laptops',
        subtitle: 'Reliable laptops for CV workshops and digital upskilling classes.',
        category: 'Education',
        priority: 'Normal',
        targetQuantity: 12,
        fulfilledQuantity: 5,
        unit: 'units',
        deadline: 'June 18, 2026',
        createdAt: _daysAgo(9),
      ),
      _need(
        id: 'need_lighthouse_uniform',
        organizationId: 'org_light_house',
        organizationName: 'Lighthouse Skills Center',
        title: 'Safe Transit Stipend Support',
        subtitle: 'Transport and uniforms for trainees joining their first internships.',
        category: 'Other',
        priority: 'Urgent',
        targetQuantity: 25,
        fulfilledQuantity: 16,
        unit: 'students',
        deadline: 'May 18, 2026',
        createdAt: _daysAgo(13),
      ),
      _need(
        id: 'need_padma_blankets',
        organizationId: 'org_padma_shelter',
        organizationName: 'Padma Shelter & School',
        title: 'Summer Mosquito Nets',
        subtitle: 'Long-lasting treated mosquito nets for girls’ dormitories.',
        category: 'Medicine',
        priority: 'Urgent',
        targetQuantity: 60,
        fulfilledQuantity: 34,
        unit: 'nets',
        deadline: 'May 21, 2026',
        createdAt: _daysAgo(17),
      ),
      _need(
        id: 'need_padma_books',
        organizationId: 'org_padma_shelter',
        organizationName: 'Padma Shelter & School',
        title: 'SSC Preparation Guidebooks',
        subtitle: 'Revision guides and model test papers for board exam candidates.',
        category: 'Education',
        priority: 'Normal',
        targetQuantity: 28,
        fulfilledQuantity: 19,
        unit: 'sets',
        deadline: 'June 9, 2026',
        createdAt: _daysAgo(5),
      ),
      _need(
        id: 'need_sundarban_water',
        organizationId: 'org_sundarban_care',
        organizationName: 'Sundarban Care Initiative',
        title: 'Water Purification Tablets',
        subtitle: 'Safe drinking water support for cyclone-affected households.',
        category: 'Medicine',
        priority: 'Urgent',
        targetQuantity: 350,
        fulfilledQuantity: 248,
        unit: 'packs',
        deadline: 'May 11, 2026',
        createdAt: _daysAgo(19),
      ),
      _need(
        id: 'need_coastal_dignity',
        organizationId: 'org_coastal_resilience',
        organizationName: 'Coastal Resilience Family Centre',
        title: 'Family Dignity Kits',
        subtitle: 'Hygiene, baby care, and essential supplies for newly enrolled households.',
        category: 'Other',
        priority: 'Urgent',
        targetQuantity: 140,
        fulfilledQuantity: 104,
        unit: 'kits',
        deadline: 'May 13, 2026',
        createdAt: _daysAgo(14),
      ),
      _need(
        id: 'need_nilphamari_shoes',
        organizationId: 'org_nilphamari_care',
        organizationName: 'Nilphamari Care House',
        title: 'School Shoes and Socks',
        subtitle: 'Uniform support before the new term begins.',
        category: 'Clothing',
        priority: 'Normal',
        targetQuantity: 52,
        fulfilledQuantity: 20,
        unit: 'sets',
        deadline: 'June 1, 2026',
        createdAt: _daysAgo(8),
      ),
      _need(
        id: 'need_smile_sylhet_tutors',
        organizationId: 'org_smile_sylhet',
        organizationName: 'Smile Sylhet Education Home',
        title: 'Exam Coaching Stipend',
        subtitle: 'Monthly stipend for part-time tutors supporting board exam students.',
        category: 'Education',
        priority: 'Normal',
        targetQuantity: 8,
        fulfilledQuantity: 3,
        unit: 'months',
        deadline: 'June 22, 2026',
        createdAt: _daysAgo(4),
      ),
      _need(
        id: 'need_safe_steps_sanitary',
        organizationId: 'org_safe_steps',
        organizationName: 'Safe Steps Barishal Home',
        title: 'Adolescent Health & Hygiene Packs',
        subtitle: 'Monthly hygiene support for teenage residents.',
        category: 'Medicine',
        priority: 'Urgent',
        targetQuantity: 70,
        fulfilledQuantity: 51,
        unit: 'packs',
        deadline: 'May 17, 2026',
        createdAt: _daysAgo(12),
      ),
    ];
  }

  List<VolunteerOpportunity> _buildVolunteerOpportunities() {
    return [
      _volunteerOpportunity(
        id: 'vol_mentor_sat',
        organizationId: 'org_shapla_home',
        organizationName: 'Shapla Child Development Home',
        title: 'Saturday Reading Mentor',
        description: 'Lead small-group reading circles and confidence-building activities for children aged 8-12.',
        location: 'Kadamtali, Dhaka',
        date: _daysFromNow(4),
        time: '10:00 AM - 1:00 PM',
        appliedUserIds: [_volunteerRituUid],
      ),
      _volunteerOpportunity(
        id: 'vol_food_pack_sorting',
        organizationId: 'org_brahmaputra_trust',
        organizationName: 'Brahmaputra Family Support Trust',
        title: 'Food Pack Sorting Team',
        description: 'Help assemble dry food hampers and label family batches before dispatch.',
        location: 'Ulipur, Kurigram',
        date: _daysFromNow(6),
        time: '9:30 AM - 2:00 PM',
        appliedUserIds: [_volunteerRahimUid],
      ),
      _volunteerOpportunity(
        id: 'vol_cv_clinic',
        organizationId: 'org_light_house',
        organizationName: 'Lighthouse Skills Center',
        title: 'Career Clinic Facilitator',
        description: 'Support trainees with CV review, mock interviews, and digital profile setup.',
        location: 'Halishahar, Chattogram',
        date: _daysFromNow(9),
        time: '2:00 PM - 5:00 PM',
      ),
      _volunteerOpportunity(
        id: 'vol_health_desk',
        organizationId: 'org_coastal_resilience',
        organizationName: 'Coastal Resilience Family Centre',
        title: 'Health Camp Registration Desk',
        description: 'Support intake, queue management, and medicine recordkeeping during the monthly clinic.',
        location: 'Ukhiya, Cox’s Bazar',
        date: _daysFromNow(5),
        time: '8:30 AM - 1:30 PM',
      ),
      _volunteerOpportunity(
        id: 'vol_exam_prep',
        organizationId: 'org_smile_sylhet',
        organizationName: 'Smile Sylhet Education Home',
        title: 'Board Exam Revision Coach',
        description: 'Run revision sessions and exam strategy workshops for SSC candidates.',
        location: 'Shibgonj, Sylhet',
        date: _daysFromNow(12),
        time: '4:00 PM - 7:00 PM',
      ),
      _volunteerOpportunity(
        id: 'vol_barishal_story',
        organizationId: 'org_safe_steps',
        organizationName: 'Safe Steps Barishal Home',
        title: 'Girls’ Storytelling Evening',
        description: 'Facilitate a weekly confidence and storytelling session for adolescent girls.',
        location: 'Rupatoli, Barishal',
        date: _daysFromNow(7),
        time: '5:00 PM - 7:00 PM',
        appliedUserIds: [_volunteerRituUid, _volunteerRahimUid],
      ),
    ];
  }

  List<Opportunity> _buildLifeOpportunities() {
    return [
      _lifeOpportunity(
        id: 'life_google_it',
        title: 'Google IT Support Scholarship Cohort',
        category: OpportunityCategory.training,
        description: 'Six-month scholarship-backed IT support training for youth transitioning into work.',
        eligibility: 'Ages 18-24, basic computer literacy, regular internet access',
        location: 'Dhaka / Remote',
        contactMethod: 'Apply via tinywings.bd/it-support by May 30',
        postedBy: _opportunityPosterUid,
        organizationId: 'org_light_house',
        deadline: _daysFromNow(38),
        createdAt: _daysAgo(3),
      ),
      _lifeOpportunity(
        id: 'life_nursing_assistant',
        title: 'Nursing Assistant Apprenticeship',
        category: OpportunityCategory.jobs,
        description: 'Paid apprenticeship placement with supervised clinical and admin training.',
        eligibility: 'Female applicants preferred, HSC completed, strong communication skills',
        location: 'Rajshahi',
        contactMethod: 'Send CV to careers@padmashelter.org',
        postedBy: _opportunityPosterUid,
        organizationId: 'org_padma_shelter',
        deadline: _daysFromNow(28),
        createdAt: _daysAgo(6),
      ),
      _lifeOpportunity(
        id: 'life_brac_scholarship',
        title: 'BRAC Urban Leadership Scholarship',
        category: OpportunityCategory.scholarships,
        description: 'Merit and need-based stipend for first-generation university students.',
        eligibility: 'Accepted into a Bangladeshi undergraduate programme, household income screening required',
        location: 'Bangladesh',
        contactMethod: 'Complete scholarship form through the support desk',
        postedBy: _opportunityPosterUid,
        deadline: _daysFromNow(44),
        createdAt: _daysAgo(9),
      ),
      _lifeOpportunity(
        id: 'life_language_fellowship',
        title: 'English Communication Fellowship',
        category: OpportunityCategory.fellowships,
        description: 'Three-month fellowship combining spoken English practice, presentation skills, and mentorship.',
        eligibility: 'Ages 16-22, committed to attending weekly sessions',
        location: 'Chattogram',
        contactMethod: 'Call 01715567805 to schedule screening',
        postedBy: _opportunityPosterUid,
        organizationId: 'org_light_house',
        deadline: _daysFromNow(19),
        createdAt: _daysAgo(2),
      ),
      _lifeOpportunity(
        id: 'life_hostel_admission',
        title: 'Girls’ Safe Hostel Admission Window',
        category: OpportunityCategory.housing,
        description: 'Protected hostel placement for girls joining vocational programmes in the city.',
        eligibility: 'Verified guardian consent and training enrollment letter required',
        location: 'Dhaka',
        contactMethod: 'Speak to the case manager through profile support',
        postedBy: _opportunityPosterUid,
        organizationId: 'org_shapla_home',
        deadline: _daysFromNow(25),
        createdAt: _daysAgo(5),
      ),
      _lifeOpportunity(
        id: 'life_design_internship',
        title: 'Junior Design Internship',
        category: OpportunityCategory.internships,
        description: 'Part-time internship covering social media design, Canva, and campaign collateral.',
        eligibility: 'Portfolio samples preferred, available 20 hours weekly',
        location: 'Dhaka',
        contactMethod: 'Email portfolio to circulars@tinywings.bd',
        postedBy: _opportunityPosterUid,
        deadline: _daysFromNow(16),
        createdAt: _daysAgo(1),
      ),
    ];
  }

  List<ChildSponsorship> _buildChildSponsorships() {
    return [
      _child(
        id: 'child_ayesha',
        organizationId: 'org_shapla_home',
        organizationName: 'Shapla Child Development Home',
        childName: 'Ayesha Khatun',
        age: 9,
        story: 'Ayesha loves science class and now reads stories to younger girls in the dormitory every evening.',
        monthlyNeeded: 2500,
        imageUrl:
            'https://images.unsplash.com/photo-1542810634-71271d05dcfe?auto=format&fit=crop&w=900&q=80',
      ),
      _child(
        id: 'child_shawon',
        organizationId: 'org_jaago_learning',
        organizationName: 'JAAGO Learning Hub Rayerbazar',
        childName: 'Shawon Das',
        age: 11,
        story: 'Shawon wants to become a football coach and has not missed a single digital class this term.',
        monthlyNeeded: 2300,
        imageUrl:
            'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?auto=format&fit=crop&w=900&q=80',
      ),
      _child(
        id: 'child_mitu',
        organizationId: 'org_padma_shelter',
        organizationName: 'Padma Shelter & School',
        childName: 'Mitu Rani',
        age: 8,
        story: 'Mitu is rebuilding her confidence through art and recently won first place in a handwriting competition.',
        monthlyNeeded: 2400,
        imageUrl:
            'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=900&q=80',
      ),
      _child(
        id: 'child_rubel',
        organizationId: 'org_nilphamari_care',
        organizationName: 'Nilphamari Care House',
        childName: 'Rubel Hossain',
        age: 10,
        story: 'Rubel is passionate about mathematics and now helps his classmates solve puzzles after lunch.',
        monthlyNeeded: 2200,
        imageUrl:
            'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80',
      ),
      _child(
        id: 'child_sumaiya',
        organizationId: 'org_coastal_resilience',
        organizationName: 'Coastal Resilience Family Centre',
        childName: 'Sumaiya Akter',
        age: 7,
        story: 'Sumaiya joined the safe learning group this year and now confidently performs rhymes in front of visitors.',
        monthlyNeeded: 2600,
        imageUrl:
            'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=900&q=80',
      ),
      _child(
        id: 'child_hasan',
        organizationId: 'org_smile_sylhet',
        organizationName: 'Smile Sylhet Education Home',
        childName: 'Hasan Ali',
        age: 12,
        story: 'Hasan spends his free time fixing broken fans and dreams of studying electrical engineering.',
        monthlyNeeded: 2800,
        imageUrl:
            'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?auto=format&fit=crop&w=900&q=80',
      ),
      _child(
        id: 'child_riti',
        organizationId: 'org_safe_steps',
        organizationName: 'Safe Steps Barishal Home',
        childName: 'Riti Sarker',
        age: 13,
        story: 'Riti leads the evening study group and wants to become a school teacher in her hometown.',
        monthlyNeeded: 3000,
        imageUrl:
            'https://images.unsplash.com/photo-1542810634-71271d05dcfe?auto=format&fit=crop&w=900&q=80',
      ),
      _child(
        id: 'child_nabil',
        organizationId: 'org_sundarban_care',
        organizationName: 'Sundarban Care Initiative',
        childName: 'Nabil Mondal',
        age: 6,
        story: 'Nabil recently moved into regular classes and is thriving with speech and reading support.',
        monthlyNeeded: 2100,
        imageUrl:
            'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80',
      ),
    ];
  }

  List<Subscription> _buildSubscriptions() {
    return [
      Subscription(
        id: 'sub_org_saymum_shapla',
        donorId: _donorSaymumUid,
        donorName: 'Saymum Rahman',
        targetType: 'org',
        targetId: 'org_shapla_home',
        targetName: 'Shapla Child Development Home',
        orgId: 'org_shapla_home',
        amount: 2500,
        status: 'active',
        startDate: _daysAgo(240),
        lastPaymentDate: _daysAgo(7),
        totalPayments: 8,
        totalAmountPaid: 20000,
      ),
      Subscription(
        id: 'sub_child_sadia_ayesha',
        donorId: _donorSadiaUid,
        donorName: 'Sadia Anjum',
        targetType: 'child',
        targetId: 'child_ayesha',
        targetName: 'Ayesha Khatun',
        orgId: 'org_shapla_home',
        amount: 2500,
        status: 'active',
        startDate: _daysAgo(180),
        lastPaymentDate: _daysAgo(5),
        totalPayments: 6,
        totalAmountPaid: 15000,
      ),
      Subscription(
        id: 'sub_org_fahim_lighthouse',
        donorId: _donorFahimUid,
        donorName: 'Fahim Chowdhury',
        targetType: 'org',
        targetId: 'org_light_house',
        targetName: 'Lighthouse Skills Center',
        orgId: 'org_light_house',
        amount: 5000,
        status: 'active',
        startDate: _daysAgo(200),
        lastPaymentDate: _daysAgo(4),
        totalPayments: 7,
        totalAmountPaid: 35000,
      ),
      Subscription(
        id: 'sub_child_nabila_rubel',
        donorId: _donorNabilaUid,
        donorName: 'Nabila Haque',
        targetType: 'child',
        targetId: 'child_rubel',
        targetName: 'Rubel Hossain',
        orgId: 'org_nilphamari_care',
        amount: 2200,
        status: 'active',
        startDate: _daysAgo(140),
        lastPaymentDate: _daysAgo(3),
        totalPayments: 5,
        totalAmountPaid: 11000,
      ),
      Subscription(
        id: 'sub_org_sadia_smile',
        donorId: _donorSadiaUid,
        donorName: 'Sadia Anjum',
        targetType: 'org',
        targetId: 'org_smile_sylhet',
        targetName: 'Smile Sylhet Education Home',
        orgId: 'org_smile_sylhet',
        amount: 1000,
        status: 'active',
        startDate: _daysAgo(120),
        lastPaymentDate: _daysAgo(2),
        totalPayments: 4,
        totalAmountPaid: 4000,
      ),
      Subscription(
        id: 'sub_org_rahim_legacy',
        donorId: _volunteerRahimUid,
        donorName: 'Md. Rahim Uddin',
        targetType: 'org',
        targetId: 'org_brahmaputra_trust',
        targetName: 'Brahmaputra Family Support Trust',
        orgId: 'org_brahmaputra_trust',
        amount: 1000,
        status: 'cancelled',
        startDate: _daysAgo(210),
        lastPaymentDate: _daysAgo(75),
        totalPayments: 3,
        totalAmountPaid: 3000,
      ),
    ];
  }

  List<Donation> _buildDonations() {
    return [
      Donation(
        id: 'don_001',
        donorId: _donorSaymumUid,
        donorName: 'Saymum Rahman',
        organizationId: 'org_shapla_home',
        organizationName: 'Shapla Child Development Home',
        type: DonationType.money,
        amount: 15000,
        paymentMethod: 'bKash',
        status: 'verified',
        notes: 'Quarterly education and meal support.',
        timestamp: _daysAgo(26),
      ),
      Donation(
        id: 'don_002',
        donorId: _donorFahimUid,
        donorName: 'Fahim Chowdhury',
        organizationId: 'org_light_house',
        organizationName: 'Lighthouse Skills Center',
        type: DonationType.money,
        amount: 22000,
        paymentMethod: 'Bank Transfer',
        status: 'verified',
        notes: 'Corporate skills lab support.',
        timestamp: _daysAgo(21),
      ),
      Donation(
        id: 'don_003',
        donorId: _donorSadiaUid,
        donorName: 'Sadia Anjum',
        organizationId: 'org_shapla_home',
        organizationName: 'Shapla Child Development Home',
        type: DonationType.items,
        itemName: 'Breakfast Nutrition Packs',
        itemCategory: 'Food',
        needId: 'need_shapla_breakfast',
        quantity: 24,
        unit: 'packs',
        approvedValue: 7200,
        status: 'verified',
        notes: 'Delivered through local grocery partner.',
        timestamp: _daysAgo(10),
      ),
      Donation(
        id: 'don_004',
        donorId: _donorNabilaUid,
        donorName: 'Nabila Haque',
        organizationId: 'org_safe_steps',
        organizationName: 'Safe Steps Barishal Home',
        type: DonationType.items,
        itemName: 'Adolescent Health & Hygiene Packs',
        itemCategory: 'Medicine',
        needId: 'need_safe_steps_sanitary',
        quantity: 18,
        unit: 'packs',
        approvedValue: 5400,
        status: 'verified',
        notes: 'Monthly recurring medicine and hygiene support.',
        timestamp: _daysAgo(8),
      ),
      Donation(
        id: 'don_005',
        donorId: _volunteerRahimUid,
        donorName: 'Md. Rahim Uddin',
        organizationId: 'org_brahmaputra_trust',
        organizationName: 'Brahmaputra Family Support Trust',
        type: DonationType.money,
        amount: 3500,
        paymentMethod: 'Nagad',
        status: 'verified',
        notes: 'Flood response top-up after field visit.',
        timestamp: _daysAgo(5),
      ),
      Donation(
        id: 'don_006',
        donorId: _adminUid,
        donorName: 'Farzana Rahman',
        organizationId: 'org_coastal_resilience',
        organizationName: 'Coastal Resilience Family Centre',
        type: DonationType.money,
        amount: 18000,
        paymentMethod: 'bKash',
        status: 'verified',
        notes: 'Emergency dignity kit replenishment.',
        timestamp: _daysAgo(4),
      ),
      Donation(
        id: 'don_007',
        donorId: _donorSaymumUid,
        donorName: 'Saymum Rahman',
        organizationId: 'org_jaago_learning',
        organizationName: 'JAAGO Learning Hub Rayerbazar',
        type: DonationType.items,
        itemName: 'Refurbished Learning Tablets',
        itemCategory: 'Education',
        needId: 'need_jaago_tablets',
        quantity: 3,
        unit: 'units',
        approvedValue: 22500,
        status: 'pending',
        estimatedValue: 22500,
        notes: 'Collection scheduled from Gulshan.',
        timestamp: _daysAgo(2),
      ),
      Donation(
        id: 'don_008',
        donorId: _donorFahimUid,
        donorName: 'Fahim Chowdhury',
        organizationId: 'org_padma_shelter',
        organizationName: 'Padma Shelter & School',
        type: DonationType.items,
        itemName: 'SSC Preparation Guidebooks',
        itemCategory: 'Education',
        needId: 'need_padma_books',
        quantity: 9,
        unit: 'sets',
        approvedValue: 6300,
        status: 'verified',
        notes: 'Printed and delivered through Rajshahi supplier.',
        timestamp: _daysAgo(6),
      ),
      Donation(
        id: 'don_009',
        donorId: _volunteerRituUid,
        donorName: 'Ritu Akter',
        organizationId: 'org_safe_steps',
        organizationName: 'Safe Steps Barishal Home',
        type: DonationType.money,
        amount: 2500,
        paymentMethod: 'bKash',
        status: 'pending',
        notes: 'Pending settlement verification from mobile wallet.',
        timestamp: _daysAgo(1),
      ),
      Donation(
        id: 'don_010',
        donorId: _donorSadiaUid,
        donorName: 'Sadia Anjum',
        organizationId: 'org_smile_sylhet',
        organizationName: 'Smile Sylhet Education Home',
        type: DonationType.money,
        amount: 7000,
        paymentMethod: 'Card',
        status: 'verified',
        notes: 'Exam coaching and hostel meal support.',
        timestamp: _daysAgo(9),
      ),
      Donation(
        id: 'don_011',
        donorId: _opportunityPosterUid,
        donorName: 'Nafisa Karim',
        organizationId: 'org_light_house',
        organizationName: 'Lighthouse Skills Center',
        type: DonationType.items,
        itemName: 'Transit stipend package',
        itemCategory: 'Other',
        needId: 'need_lighthouse_uniform',
        quantity: 6,
        unit: 'students',
        approvedValue: 9000,
        status: 'verified',
        notes: 'Covered for first internship cohort.',
        timestamp: _daysAgo(3),
      ),
      Donation(
        id: 'don_012',
        donorId: _donorNabilaUid,
        donorName: 'Nabila Haque',
        organizationId: 'org_nilphamari_care',
        organizationName: 'Nilphamari Care House',
        type: DonationType.money,
        amount: 4200,
        paymentMethod: 'Nagad',
        status: 'verified',
        notes: 'School shoe support before new term.',
        timestamp: _daysAgo(7),
      ),
    ];
  }

  List<Post> _buildPosts() {
    return [
      Post(
        id: 'post_001',
        authorId: _adminUid,
        content:
            'This week our partner homes confirmed 34 more children with uninterrupted school attendance. Thank you for helping us keep momentum high ahead of exam season.',
        timestamp: _daysAgo(2),
        tag: 'impact',
        likes: [_donorSaymumUid, _donorSadiaUid, _volunteerRahimUid],
        comments: [
          PostComment(
            id: 'comment_001',
            userId: _donorSaymumUid,
            userName: 'Saymum Rahman',
            content: 'The exam support updates are so encouraging.',
            timestamp: _daysAgo(1),
          ),
        ],
      ),
      Post(
        id: 'post_002',
        authorId: _orgManagerUid,
        content:
            'Breakfast nutrition packs reached every child in the Shapla home this morning. Attendance at class was full and the younger group finished their reading session smiling.',
        timestamp: _daysAgo(4),
        tag: 'nutrition',
        imageData:
            'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80',
        likes: [_donorSadiaUid, _volunteerRituUid],
      ),
      Post(
        id: 'post_003',
        authorId: _opportunityPosterUid,
        content:
            'A new internship partner in Dhaka agreed to reserve two junior design seats for youth from our Lighthouse cohort. Applications open this week.',
        timestamp: _daysAgo(3),
        tag: 'opportunity',
        likes: [_adminUid, _volunteerRahimUid],
      ),
      Post(
        id: 'post_004',
        authorId: _volunteerRahimUid,
        content:
            'Spent Friday in Ulipur helping sort food packs before dispatch. The trust team had every family list ready, which made the handover smooth and dignified.',
        timestamp: _daysAgo(5),
        tag: 'field',
        likes: [_adminUid, _donorNabilaUid, _volunteerRituUid],
      ),
      Post(
        id: 'post_005',
        authorId: _donorSaymumUid,
        content:
            'Visited the reading corner at Shapla Home today. Ayesha proudly showed me the storybook she finished on her own for the first time.',
        timestamp: _daysAgo(8),
        tag: 'sponsorship',
        likes: [_adminUid, _orgManagerUid, _donorSadiaUid],
      ),
      Post(
        id: 'post_006',
        authorId: _adminUid,
        content:
            'Our Barishal adolescent health packs are now at 73% coverage for the month. One more push and every girl in Safe Steps will have a full set before the next clinic.',
        timestamp: _daysAgo(6),
        tag: 'health',
        likes: [_donorNabilaUid, _volunteerRituUid],
      ),
    ];
  }

  List<VolunteerApplication> _buildApplications() {
    return [
      VolunteerApplication(
        id: 'app_mentor_rahim',
        userId: _volunteerRahimUid,
        userName: 'Md. Rahim Uddin',
        opportunityId: 'vol_cv_clinic',
        opportunityTitle: 'Career Clinic Facilitator',
        organizationName: 'Lighthouse Skills Center',
        status: ApplicationStatus.accepted,
        appliedAt: _daysAgo(9),
        notes: 'Available for mock interviews and basic CV review.',
      ),
      VolunteerApplication(
        id: 'app_story_ritu',
        userId: _volunteerRituUid,
        userName: 'Ritu Akter',
        opportunityId: 'vol_barishal_story',
        opportunityTitle: 'Girls’ Storytelling Evening',
        organizationName: 'Safe Steps Barishal Home',
        status: ApplicationStatus.accepted,
        appliedAt: _daysAgo(4),
        notes: 'Can support weekly through the exam break.',
      ),
      VolunteerApplication(
        id: 'app_food_pack_rahim',
        userId: _volunteerRahimUid,
        userName: 'Md. Rahim Uddin',
        opportunityId: 'vol_food_pack_sorting',
        opportunityTitle: 'Food Pack Sorting Team',
        organizationName: 'Brahmaputra Family Support Trust',
        status: ApplicationStatus.pending,
        appliedAt: _daysAgo(2),
        notes: 'Travelling from Dhaka on Friday night.',
      ),
      VolunteerApplication(
        id: 'app_exam_ritu',
        userId: _volunteerRituUid,
        userName: 'Ritu Akter',
        opportunityId: 'vol_exam_prep',
        opportunityTitle: 'Board Exam Revision Coach',
        organizationName: 'Smile Sylhet Education Home',
        status: ApplicationStatus.rejected,
        appliedAt: _daysAgo(11),
        notes: 'Rejected due to schedule conflict with ongoing school placement.',
      ),
    ];
  }

  List<AppNotification> _buildNotifications() {
    return [
      AppNotification(
        id: 'notif_001',
        userId: _donorSaymumUid,
        title: 'Sponsorship update from Shapla Home',
        message: 'Ayesha completed her monthly literacy milestone and sent a new classroom update.',
        type: NotificationType.sponsorship,
        timestamp: _daysAgo(1),
        relatedId: 'child_ayesha',
      ),
      AppNotification(
        id: 'notif_002',
        userId: _volunteerRahimUid,
        title: 'Volunteer application approved',
        message: 'Your application for the Career Clinic Facilitator session was approved by Lighthouse Skills Center.',
        type: NotificationType.volunteer,
        timestamp: _hoursAgo(18),
        relatedId: 'app_mentor_rahim',
      ),
      AppNotification(
        id: 'notif_003',
        userId: _orgManagerUid,
        title: 'New verified contribution recorded',
        message: 'A verified item donation was linked to the Breakfast Nutrition Packs need.',
        type: NotificationType.donation,
        timestamp: _hoursAgo(12),
        relatedId: 'don_003',
      ),
      AppNotification(
        id: 'notif_004',
        userId: _adminUid,
        title: 'Donation review pending',
        message: 'One new in-kind donation for learning tablets is awaiting verification.',
        type: NotificationType.admin,
        timestamp: _hoursAgo(10),
        relatedId: 'don_007',
      ),
      AppNotification(
        id: 'notif_005',
        userId: _opportunityPosterUid,
        title: 'High engagement on internship circular',
        message: 'The junior design internship post reached 38 profile views in the first 24 hours.',
        type: NotificationType.social,
        timestamp: _hoursAgo(7),
      ),
      AppNotification(
        id: 'notif_006',
        userId: _donorNabilaUid,
        title: 'Payment recorded',
        message: 'Your monthly sponsorship payment for Rubel Hossain was successfully recorded.',
        type: NotificationType.donation,
        timestamp: _hoursAgo(5),
        relatedId: 'sub_child_nabila_rubel',
      ),
    ];
  }

  List<SupportTicket> _buildSupportTickets() {
    return [
      SupportTicket(
        id: 'ticket_001',
        userId: _donorSaymumUid,
        userName: 'Saymum Rahman',
        userEmail: _donorSaymumEmail,
        category: 'Question',
        subject: 'Child progress updates cadence',
        message: 'Can sponsorship updates be grouped at the end of each month instead of arriving separately?',
        timestamp: _daysAgo(9).millisecondsSinceEpoch,
        status: 'resolved',
        adminReply: 'Yes. Monthly digest notifications have been enabled for your profile.',
        repliedAt: _daysAgo(7).millisecondsSinceEpoch,
        isReadByUser: true,
        isReadByAdmin: true,
      ),
      SupportTicket(
        id: 'ticket_002',
        userId: _volunteerRahimUid,
        userName: 'Md. Rahim Uddin',
        userEmail: _volunteerRahimEmail,
        category: 'Suggestion',
        subject: 'Volunteer certificate export',
        message: 'It would help if accepted volunteers could download a simple participation letter after an event.',
        timestamp: _daysAgo(6).millisecondsSinceEpoch,
        status: 'pending',
        isReadByUser: true,
        isReadByAdmin: false,
      ),
      SupportTicket(
        id: 'ticket_003',
        userId: _orgManagerUid,
        userName: 'Mahmudul Hasan',
        userEmail: _orgManagerEmail,
        category: 'Question',
        subject: 'Bulk child profile image upload',
        message: 'Is there a recommended image size for sponsorship profiles to keep loading consistent on slower connections?',
        timestamp: _daysAgo(4).millisecondsSinceEpoch,
        status: 'resolved',
        adminReply: 'Yes. 1200px wide JPEG under 500KB keeps load times stable on web and mobile.',
        repliedAt: _daysAgo(3).millisecondsSinceEpoch,
        isReadByUser: true,
        isReadByAdmin: true,
      ),
    ];
  }

  List<Map<String, Object?>> _buildActivityLogs() {
    return [
      _activityLog(
        id: 'log_001',
        actorId: _adminUid,
        actorName: 'Farzana Rahman',
        action: 'verified_donation',
        entityType: 'donation',
        entityId: 'don_007',
        timestamp: _hoursAgo(10),
        summary: 'Reviewed pending tablet contribution for JAAGO Learning Hub.',
      ),
      _activityLog(
        id: 'log_002',
        actorId: _orgManagerUid,
        actorName: 'Mahmudul Hasan',
        action: 'posted_need',
        entityType: 'need',
        entityId: 'need_shapla_schoolbags',
        timestamp: _daysAgo(11),
        summary: 'Published a new school bag and stationery requirement for incoming children.',
      ),
      _activityLog(
        id: 'log_003',
        actorId: _volunteerRahimUid,
        actorName: 'Md. Rahim Uddin',
        action: 'applied_volunteer_opportunity',
        entityType: 'application',
        entityId: 'app_food_pack_rahim',
        timestamp: _daysAgo(2),
        summary: 'Applied for the Ulipur food pack sorting shift.',
      ),
      _activityLog(
        id: 'log_004',
        actorId: _donorSaymumUid,
        actorName: 'Saymum Rahman',
        action: 'renewed_subscription',
        entityType: 'subscription',
        entityId: 'sub_org_saymum_shapla',
        timestamp: _daysAgo(7),
        summary: 'Monthly sponsorship renewed successfully for Shapla Child Development Home.',
      ),
      _activityLog(
        id: 'log_005',
        actorId: _opportunityPosterUid,
        actorName: 'Nafisa Karim',
        action: 'published_opportunity',
        entityType: 'life_opportunity',
        entityId: 'life_design_internship',
        timestamp: _daysAgo(1),
        summary: 'Published the junior design internship circular for Dhaka.',
      ),
    ];
  }

  List<Map<String, Object?>> _buildHistoryRecords() {
    return [
      _historyRecord(
        id: 'history_need_tablets',
        entityType: 'need',
        entityId: 'need_jaago_tablets',
        status: 'approved',
        timestamp: _daysAgo(22),
        note: 'Need approved after programme manager review.',
      ),
      _historyRecord(
        id: 'history_need_tablets_partial',
        entityType: 'need',
        entityId: 'need_jaago_tablets',
        status: 'partially_fulfilled',
        timestamp: _daysAgo(2),
        note: 'Three additional refurbished tablets pledged and queued for pickup.',
      ),
      _historyRecord(
        id: 'history_sub_ayesha_start',
        entityType: 'subscription',
        entityId: 'sub_child_sadia_ayesha',
        status: 'active',
        timestamp: _daysAgo(180),
        note: 'Child sponsorship activated for Ayesha Khatun.',
      ),
      _historyRecord(
        id: 'history_sub_rahim_cancel',
        entityType: 'subscription',
        entityId: 'sub_org_rahim_legacy',
        status: 'cancelled',
        timestamp: _daysAgo(74),
        note: 'Sponsor paused recurring gift due to travel and temporary cash-flow constraints.',
      ),
    ];
  }

  Organization _organization({
    required String id,
    required String name,
    required String location,
    required String phone,
    required String email,
    required String imageUrl,
    required String description,
    required String about,
    required int totalChildren,
    required int impactChildCount,
    required bool isFeatured,
  }) {
    return Organization(
      id: id,
      name: name,
      location: location,
      description: description,
      about: about,
      phone: phone,
      email: email,
      imageUrl: imageUrl,
      status: VerificationStatus.verified,
      isFeatured: isFeatured,
      totalChildren: totalChildren,
      impactChildCount: impactChildCount,
      submittedBy: _adminUid,
      submittedAt: _daysAgo(430),
      verifiedBy: _adminUid,
      approvedAt: _daysAgo(420),
      verificationNotes: 'Operational documents, field references, and child safeguarding checklist verified.',
    );
  }

  Need _need({
    required String id,
    required String organizationId,
    required String organizationName,
    required String title,
    required String subtitle,
    required String category,
    required String priority,
    required double targetQuantity,
    required double fulfilledQuantity,
    required String unit,
    required String deadline,
    required DateTime createdAt,
  }) {
    return Need(
      id: id,
      organizationId: organizationId,
      organizationName: organizationName,
      title: title,
      category: category,
      priority: priority,
      subtitle: subtitle,
      quantityOrAmount: '${targetQuantity.toInt()} $unit',
      targetQuantity: targetQuantity,
      fulfilledQuantity: fulfilledQuantity,
      unit: unit,
      deadline: deadline,
      status: fulfilledQuantity >= targetQuantity ? 'fulfilled' : 'approved',
      createdAt: createdAt,
    );
  }

  VolunteerOpportunity _volunteerOpportunity({
    required String id,
    required String organizationId,
    required String organizationName,
    required String title,
    required String description,
    required String location,
    required DateTime date,
    required String time,
    List<String> appliedUserIds = const [],
  }) {
    return VolunteerOpportunity(
      id: id,
      organizationId: organizationId,
      organizationName: organizationName,
      title: title,
      description: description,
      location: location,
      date: date,
      time: time,
      status: OpportunityStatus.approved,
      requiredSkills: const ['communication', 'coordination'],
      maxVolunteers: 12,
      appliedUserIds: appliedUserIds,
    );
  }

  Opportunity _lifeOpportunity({
    required String id,
    required String title,
    required OpportunityCategory category,
    required String description,
    required String eligibility,
    required String location,
    required String contactMethod,
    required String postedBy,
    String? organizationId,
    DateTime? deadline,
    required DateTime createdAt,
  }) {
    return Opportunity(
      id: id,
      title: title,
      category: category,
      description: description,
      eligibility: eligibility,
      deadline: deadline,
      location: location,
      contactMethod: contactMethod,
      postedBy: postedBy,
      organizationId: organizationId,
      status: OpportunityStatus.approved,
      createdAt: createdAt,
    );
  }

  ChildSponsorship _child({
    required String id,
    required String organizationId,
    required String organizationName,
    required String childName,
    required int age,
    required String story,
    required double monthlyNeeded,
    required String imageUrl,
  }) {
    return ChildSponsorship(
      id: id,
      organizationId: organizationId,
      organizationName: organizationName,
      childName: childName,
      age: age,
      story: story,
      imageUrl: imageUrl,
      monthlyNeeded: monthlyNeeded,
    );
  }

  Map<String, Object?> _activityLog({
    required String id,
    required String actorId,
    required String actorName,
    required String action,
    required String entityType,
    required String entityId,
    required DateTime timestamp,
    required String summary,
  }) {
    return {
      'id': id,
      'actorId': actorId,
      'actorName': actorName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'summary': summary,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, Object?> _historyRecord({
    required String id,
    required String entityType,
    required String entityId,
    required String status,
    required DateTime timestamp,
    required String note,
  }) {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  DateTime _daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

  DateTime _hoursAgo(int hours) =>
      DateTime.now().subtract(Duration(hours: hours));

  DateTime _daysFromNow(int days) => DateTime.now().add(Duration(days: days));
}
