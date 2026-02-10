import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';

class SankeyNode {
  final String label;
  final double value;
  final Color color;
  final int level; // 0 = source, 1 = middle, 2 = destination
  double y = 0; // Calculated position
  double height = 0; // Calculated height

  SankeyNode({
    required this.label,
    required this.value,
    required this.color,
    required this.level,
  });
}

class SankeyLink {
  final String source;
  final String target;
  final double value;
  final Color color;
  double sourceY = 0; // Calculated source position
  double targetY = 0; // Calculated target position

  SankeyLink({
    required this.source,
    required this.target,
    required this.value,
    required this.color,
  });
}

class SankeyChart extends StatelessWidget {
  final List<SankeyNode> nodes;
  final List<SankeyLink> links;
  final double totalIncome;

  const SankeyChart({
    super.key,
    required this.nodes,
    required this.links,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SankeyPainter(
        nodes: nodes,
        links: links,
        totalIncome: totalIncome,
      ),
      child: Container(),
    );
  }
}

class SankeyPainter extends CustomPainter {
  final List<SankeyNode> nodes;
  final List<SankeyLink> links;
  final double totalIncome;

  SankeyPainter({
    required this.nodes,
    required this.links,
    required this.totalIncome,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeWidth = 10.0;
    final leftPadding = 60.0;
    final rightPadding = 240.0; // More space for labels on the right
    final availableWidth = size.width - leftPadding - rightPadding;
    final columnSpacing = availableWidth;

    // Group nodes by level
    final levelNodes = <int, List<SankeyNode>>{};
    for (final node in nodes) {
      levelNodes.putIfAbsent(node.level, () => []).add(node);
    }

    // Calculate vertical positions
    final spacing = 30.0;
    for (final level in levelNodes.keys) {
      final levelNodeList = levelNodes[level]!;
      final totalValue = levelNodeList.fold<double>(0, (sum, node) => sum + node.value);

      // Calculate heights based on value proportions
      for (final node in levelNodeList) {
        node.height = math.max(8.0, (node.value / totalValue) * (size.height - spacing * (levelNodeList.length - 1)));
      }

      // Center vertically
      final totalHeight = levelNodeList.fold<double>(0, (sum, node) => sum + node.height) +
                          spacing * (levelNodeList.length - 1);
      double currentY = (size.height - totalHeight) / 2;

      for (final node in levelNodeList) {
        node.y = currentY;
        currentY += node.height + spacing;
      }
    }

    // Calculate link positions
    final linkOffsets = <String, double>{};
    for (final node in nodes) {
      linkOffsets['${node.label}_source'] = 0;
      linkOffsets['${node.label}_target'] = 0;
    }

    for (final link in links) {
      final sourceNode = nodes.firstWhere((n) => n.label == link.source);
      final targetNode = nodes.firstWhere((n) => n.label == link.target);

      final sourceLinkHeight = (link.value / sourceNode.value) * sourceNode.height;
      final targetLinkHeight = (link.value / targetNode.value) * targetNode.height;

      link.sourceY = sourceNode.y + linkOffsets['${link.source}_source']!;
      link.targetY = targetNode.y + linkOffsets['${link.target}_target']!;

      linkOffsets['${link.source}_source'] = linkOffsets['${link.source}_source']! + sourceLinkHeight;
      linkOffsets['${link.target}_target'] = linkOffsets['${link.target}_target']! + targetLinkHeight;
    }

    // Draw links first (so they appear behind nodes)
    for (final link in links) {
      final sourceNode = nodes.firstWhere((n) => n.label == link.source);
      final targetNode = nodes.firstWhere((n) => n.label == link.target);

      final sourceX = leftPadding + (sourceNode.level * columnSpacing);
      final targetX = leftPadding + (targetNode.level * columnSpacing);

      _drawLink(canvas, sourceX, targetX, nodeWidth, link, sourceNode, targetNode);
    }

    // Draw nodes
    for (final node in nodes) {
      final x = leftPadding + (node.level * columnSpacing);
      _drawNode(canvas, x, nodeWidth, node);
    }
  }

  void _drawLink(Canvas canvas, double sourceX, double targetX, double nodeWidth,
                 SankeyLink link, SankeyNode sourceNode, SankeyNode targetNode) {
    final paint = Paint()
      ..color = link.color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final sourceLinkHeight = (link.value / sourceNode.value) * sourceNode.height;
    final targetLinkHeight = (link.value / targetNode.value) * targetNode.height;

    final path = Path();

    // Start from right edge of source node
    path.moveTo(sourceX + nodeWidth, link.sourceY);
    path.lineTo(sourceX + nodeWidth, link.sourceY + sourceLinkHeight);

    // Bezier curve to target
    final controlX1 = sourceX + nodeWidth + (targetX - sourceX - nodeWidth) * 0.5;
    final controlX2 = sourceX + nodeWidth + (targetX - sourceX - nodeWidth) * 0.5;

    path.cubicTo(
      controlX1, link.sourceY + sourceLinkHeight,
      controlX2, link.targetY + targetLinkHeight,
      targetX, link.targetY + targetLinkHeight,
    );

    path.lineTo(targetX, link.targetY);

    path.cubicTo(
      controlX2, link.targetY,
      controlX1, link.sourceY,
      sourceX + nodeWidth, link.sourceY,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawNode(Canvas canvas, double x, double nodeWidth, SankeyNode node) {
    final paint = Paint()
      ..color = node.color
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, node.y, nodeWidth, node.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Draw label
    final percentage = (node.value / totalIncome * 100).toStringAsFixed(1);
    final amount = '\$${(node.value / 100).toStringAsFixed(2)}';

    final labelSpan = TextSpan(
      text: node.label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
        fontFamily: 'SF Pro Display',
      ),
      children: [
        TextSpan(
          text: '\n$amount ($percentage%)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    );

    textPainter.layout(maxWidth: 200);

    // Position label - always to the right of nodes
    final labelX = x + nodeWidth + 16;
    final labelY = node.y + (node.height - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(covariant SankeyPainter oldDelegate) {
    return true;
  }
}
