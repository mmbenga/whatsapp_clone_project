import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_services.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: const Text(
          'WhatsApp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              _handlePopupMenuSelection(value);
            },
            itemBuilder: (BuildContext context) {
              return {'New group', 'New broadcast', 'Linked devices', 'Settings', 'Logout'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt, size: 20)),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('CHATS'),
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Color(0xFF075E54),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCameraTab(),
          _buildChatsTab(),
          _buildStatusTab(),
          _buildCallsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCameraTab() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.photo_camera, color: Colors.white, size: 50),
            SizedBox(height: 16),
            Text(
              'Camera',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsTab() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildArchiveBanner(),
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return _buildChatListItem(chat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveBanner() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: const [
          Icon(Icons.archive, color: Color(0xFF075E54)),
          SizedBox(width: 16),
          Text(
            'Archived',
            style: TextStyle(
              color: Color(0xFF075E54),
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            '3',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(Map<String, dynamic> chat) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              backgroundImage: chat['imageUrl'] != null 
                  ? CachedNetworkImageProvider(chat['imageUrl']!)
                  : null,
              child: chat['imageUrl'] == null 
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            if (chat['isOnline'] == true)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
      title: Text(
        chat['name'],
        style: TextStyle(
          fontWeight: chat['hasUnread'] ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Row(
        children: [
          if (chat['isMuted'] == true)
            const Icon(Icons.volume_off, size: 16, color: Colors.grey),
          if (chat['isMuted'] == true) const SizedBox(width: 4),
          Expanded(
            child: Text(
              chat['lastMessage'],
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: chat['hasUnread'] ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['time'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: chat['hasUnread'] ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (chat['unreadCount'] > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat['unreadCount'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chat['id'],
              chatName: chat['name'],
            ),
          ),
        );
      },
      onLongPress: () {
        _showChatOptions(chat);
      },
    );
  }

  Widget _buildStatusTab() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildMyStatus(),
          _buildStatusUpdates(),
        ],
      ),
    );
  }

  Widget _buildMyStatus() {
    return ListTile(
      leading: Stack(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.add, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      title: const Text(
        'My status',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Tap to add status update'),
      onTap: () {
        // Add status functionality
      },
    );
  }

  Widget _buildStatusUpdates() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent updates',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _statusUpdates.length,
              itemBuilder: (context, index) {
                final status = _statusUpdates[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF25D366), width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: status['imageUrl'] != null 
                          ? CachedNetworkImageProvider(status['imageUrl']!)
                          : null,
                      child: status['imageUrl'] == null 
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                  ),
                  title: Text(
                    status['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(status['time']),
                  onTap: () {
                    // View status functionality
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallsTab() {
    return ListView.builder(
      itemCount: _calls.length,
      itemBuilder: (context, index) {
        final call = _calls[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            backgroundImage: call['imageUrl'] != null 
                ? CachedNetworkImageProvider(call['imageUrl']!)
                : null,
            child: call['imageUrl'] == null 
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          title: Text(
            call['name'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Row(
            children: [
              Icon(
                call['type'] == 'outgoing' ? Icons.call_made : Icons.call_received,
                size: 16,
                color: call['isMissed'] ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(call['time']),
            ],
          ),
          trailing: Icon(
            call['isVideo'] ? Icons.videocam : Icons.call,
            color: const Color(0xFF075E54),
          ),
          onTap: () {
            // Initiate call
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Camera
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF075E54),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        );
      case 1: // Chats
        return FloatingActionButton(
          onPressed: () {
            _showNewChatDialog();
          },
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.chat, color: Colors.white),
        );
      case 2: // Status
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.grey[300],
              mini: true,
              child: const Icon(Icons.edit, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF25D366),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ],
        );
      case 3: // Calls
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.add_call, color: Colors.white),
        );
      default:
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.chat, color: Colors.white),
        );
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search chats'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF075E54)),
              title: const Text('New group'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to create group
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts, color: Color(0xFF075E54)),
              title: const Text('New contact'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add contact
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(Map<String, dynamic> chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.archive, color: Color(0xFF075E54)),
            title: const Text('Archive chat'),
            onTap: () {
              Navigator.pop(context);
              // Archive chat logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_off, color: Color(0xFF075E54)),
            title: const Text('Mute notifications'),
            onTap: () {
              Navigator.pop(context);
              // Mute logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete chat'),
            onTap: () {
              Navigator.pop(context);
              // Delete chat logic
            },
          ),
        ],
      ),
    );
  }

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'Logout':
        _auth.signOut();
        break;
      case 'Settings':
        // Navigate to settings
        break;
      case 'New group':
        _showNewChatDialog();
        break;
      default:
        // Handle other options
        break;
    }
  }

  // Mock data - Replace with actual data from Firestore
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'John Doe',
      'lastMessage': 'Hey there! How are you doing?',
      'time': '10:30 AM',
      'unreadCount': 2,
      'hasUnread': true,
      'isOnline': true,
      'isMuted': false,
      'imageUrl': null,
    },
    {
      'id': '2',
      'name': 'Alice Smith',
      'lastMessage': 'Meeting at 3 PM tomorrow',
      'time': '9:15 AM',
      'unreadCount': 0,
      'hasUnread': false,
      'isOnline': false,
      'isMuted': true,
      'imageUrl': null,
    },
    {
      'id': '3',
      'name': 'Family Group',
      'lastMessage': 'Mom: Dinner is ready!',
      'time': 'Yesterday',
      'unreadCount': 5,
      'hasUnread': true,
      'isOnline': false,
      'isMuted': false,
      'imageUrl': null,
    },
  ];

  final List<Map<String, dynamic>> _statusUpdates = [
    {
      'name': 'John Doe',
      'time': 'Just now',
      'imageUrl': null,
    },
    {
      'name': 'Alice Smith',
      'time': '25 minutes ago',
      'imageUrl': null,
    },
  ];

  final List<Map<String, dynamic>> _calls = [
    {
      'name': 'John Doe',
      'time': 'Today, 10:30 AM',
      'type': 'outgoing',
      'isMissed': false,
      'isVideo': false,
      'imageUrl': null,
    },
    {
      'name': 'Alice Smith',
      'time': 'Yesterday, 3:15 PM',
      'type': 'incoming',
      'isMissed': true,
      'isVideo': true,
      'imageUrl': null,
    },
  ];
}