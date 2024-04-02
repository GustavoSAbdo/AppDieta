import 'package:hive/hive.dart';
import 'package:complete/paginaHome/hive/hive_food_item.dart'; // Substitua pelo caminho correto para o arquivo que contém a classe HiveFoodItem

part 'hive_refeicao.g.dart'; // Nome do arquivo gerado pelo Hive

@HiveType(typeId: 2)
class HiveRefeicao {
  @HiveField(0)
  List<HiveFoodItem> items;

  HiveRefeicao({List<HiveFoodItem>? items}) : items = items ?? [];
}