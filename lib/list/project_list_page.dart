import 'package:flutter/material.dart';
import 'package:flutter_widgets/entity/project_list_entity.dart';
import 'package:flutter_widgets/net/net.dart';
import 'package:provider/provider.dart';

class ProjectListPage extends StatefulWidget {
  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  @override
  Widget build(BuildContext context) {
    print('--------build page----------');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('项目'),
        backgroundColor: Colors.white,
      ),
      body: ProviderWidget<ProjectViewModel>(
        model: ProjectViewModel(),
        onReady: (model) => model.refresh(),
        builder: (context, model, _) {
          print('--------build list----------');
          return NotificationListener(
            child: RefreshIndicator(
              child: (model.list?.length ?? 0) == 0
                  ? Container()
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        ProjectListDataData item = model.list[index];
                        return _buildItem(item);
                      },
                      itemCount: model.list?.length ?? 0,
                    ),
              onRefresh: () => model.refresh(),
            ),
            onNotification: (ScrollNotification notify) {
              /// 判断滑动距离和滚动方向
              if (notify.metrics.pixels >=
                      (notify.metrics.maxScrollExtent - 400) &&
                  notify.metrics.axis == Axis.vertical) {
                model.loadMore();
              }
              return true;
            },
          );
        },
      ),
    );
  }

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
}

class ProviderWidget<T extends ChangeNotifier> extends StatefulWidget {
  final T model;

  final Widget child;

  final ValueWidgetBuilder<T> builder;
  final Function(T) onReady;

  const ProviderWidget(
      {Key key, this.model, this.builder, this.onReady, this.child})
      : super(key: key);

  @override
  _ProviderWidgetState createState() => _ProviderWidgetState<T>();
}

class _ProviderWidgetState<T extends ChangeNotifier>
    extends State<ProviderWidget<T>> {
  T model;

  @override
  void initState() {
    model = widget.model;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onReady != null) {
        widget.onReady(model);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => model,
      child: Consumer(
        builder: widget.builder,
        child: widget.child,
      ),
    );
  }
}

class ProjectViewModel extends ChangeNotifier {
  int _index = 1;

  List<ProjectListDataData> list;

  bool _isLoading = false;

  refresh() async {
    if (_isLoading) return;
    _index = 1;
    await _loadData();
  }

  loadMore() async {
    if (_isLoading) return;
    _index++;
    await _loadData();
  }

  _loadData() async {
    _isLoading = true;
    Net.instance.get('project/list/$_index/json',
        queryParameters: {'cid': 294}).then((res) {
      ProjectListEntity entity = ProjectListEntity.fromJson(res);
      if (entity.errorCode == 0) {
        if (_index == 1) {
          list = entity.data.datas;
        } else {
          list.addAll(entity.data.datas);
        }
        notifyListeners();
      } else {
        throw Exception('响应错误');
      }
    }).catchError((e) {
      print(e.toString());
    }).whenComplete(() {
      _isLoading = false;
    });
  }
}
