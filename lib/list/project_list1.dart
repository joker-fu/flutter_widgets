import 'package:flutter/material.dart';
import 'package:flutter_widgets/entity/project_list_entity.dart';
import 'package:flutter_widgets/net/net.dart';

class ProjectListPage extends StatefulWidget {
  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  List<ProjectListDataData> list = List();

  int _pageIndex = 1;

  @override
  void initState() {
    //初始化加载数据
    loadData(_pageIndex);
    super.initState();
  }

  /// 构建界面
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('项目'),
        backgroundColor: Colors.white,
      ),
      body: NotificationListener(
        child: RefreshIndicator(
            color: Colors.black87,
            child: ListView.builder(
              itemBuilder: (context, index) {
                var item = list[index];
                return _buildItem(item);
              },
              itemCount: list.length,
            ),
            onRefresh: () {
              // 下拉刷新
              _pageIndex = 1;
              return loadData(_pageIndex);
            }),
        onNotification: (ScrollNotification notify) {
          /// 判断滑动距离【小于等于400 】和 滚动方向
          if (notify.metrics.pixels >= (notify.metrics.maxScrollExtent - 400) &&
              notify.metrics.axis == Axis.vertical) {
            // 加载更多
            _pageIndex += 1;
            loadData(_pageIndex);
          }
          return true;
        },
      ),
    );
  }

  /// 构建 item
  Widget _buildItem(ProjectListDataData item) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Image.network(
              item.envelopePic,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      wordSpacing: 0.8,
                      height: 1.2),
                ),
                Text(
                  item.desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '作者：${item.author}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      wordSpacing: 0.8,
                      height: 1.2),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  /// 请求列表数据
  loadData(int pageIndex) async {
    await Net.instance.get('project/list/$pageIndex/json',
        queryParameters: {'cid': 294}).then((res) {
      ProjectListEntity entity = ProjectListEntity.fromJson(res);
      if (entity.errorCode == 0) {
        setState(() {
          if (pageIndex == 1) {
            list = entity.data.datas;
          } else {
            list.addAll(entity.data.datas);
          }
        });
      } else {
        throw Exception('响应错误');
      }
    }).catchError((e) {
      print(e.toString());
    }).whenComplete(() {});
  }
}
